class ProfileEditorController < MyProfileController

  protect 'edit_profile', :profile, :except => [:destroy_profile]
  protect 'destroy_profile', :profile, :only => [:destroy_profile]

  skip_before_action :verify_authenticity_token, only: [:google_map]
  before_action :access_welcome_page, :only => [:welcome_page]
  before_action :back_to
  before_action :forbid_destroy_profile, :only => [:destroy_profile]
  before_action :check_user_can_edit_header_footer, :only => [:header_footer]
  before_action :location_active, :only => [:locality]
  helper_method :has_welcome_page
  helper CustomFieldsHelper

  include CategoriesHelper
  include SearchTags

  def index
    @pending_tasks = Task.to(profile).pending.without_spam
  end

  helper :profile

  def informations
    @profile_data = profile
    @kinds = environment.kinds.where(:type => profile.type)
    profile_params = params[:profile_data].to_h

    if request.post?
      profile_params[:fields_privacy] ||= {} if profile.person? && profile_params.is_a?(Hash)
      Profile.transaction do
        Image.transaction do
          begin
            # TODO: Move this somewhere else.
            @plugins.dispatch(:profile_editor_transaction_extras)

            # TODO: This is unsafe! Add sanitizer
            @profile_data.update!(profile_params)
            redirect_to :action => 'index', :profile => profile.identifier
          rescue
            profile.identifier = params[:profile] if profile.identifier.blank?
          end
        end
      end
    end
  end

  def remote_edit
    if request.post?
      if profile.update(params[:profile_data])
        if params.has_key?(:field)
          response = render_to_string(partial: 'profile_editor/edit_in_place_field',
                                      locals: {:field => params[:field],
                                               :type => params[:type],
                                               :content => profile.send(params[:field])})
        else
          response = render_to_string(partial: 'blocks/profile_big_image')
        end
        respond_to do |format|
          format.js do
            render :json => {
                :html => response,
                :response => 'success'
             }
          end
        end
      else
        key, error = profile.errors.first
        respond_to do |format|
          format.js do
            render :json => {
                :response => 'error',
                :msg => "Sorry, #{key} #{error}"
             }
          end
        end
      end
    end
  end

  def preferences
    update_profile_data
  end

  def categories
    regions = profile.categories.where(type: 'Region').map(&:id).map(&:to_s)
    params[:profile_data][:category_ids] += regions if params[:profile_data].present?
    update_profile_data
  end

  def regions
    categories = profile.categories.where(type: 'Category').map(&:id).map(&:to_s)
    params[:profile_data][:category_ids] += categories if params[:profile_data].present?
    update_profile_data
  end

  def tags
    update_profile_data
  end

  def privacy
    if params[:profile_data].present?
      profile.update_access_level(params[:profile_data].delete(:access))
      profile.update_access_level(params[:profile_data].delete(:wall_access), 'wall')
    end
    update_profile_data
  end

  def locality
    @profile_data = profile
    if request.post?
      begin
        country = params[:profile_data][:country]
        city = params[:profile_data][:city]
        state = params[:profile_data][:state]
        nregion = NationalRegion.validate!(city, state, country)
        unless nregion.blank?
          params[:profile_data][:national_region_code] = nregion.national_region_code
        end

        if profile.update!(params[:profile_data])
          BlockSweeper.expire_blocks profile.blocks.select{ |b| b.class == LocationBlock }
          session[:notice] = _('Address was updated successfully!')
        end
      rescue
        session[:notice] = _('Address could not be saved!')
      end
    end
  end

  def enable
    @to_enable = profile
    if request.post? && params[:confirmation]
      unless @to_enable.update_attribute('enabled', true)
        session[:notice] = _('%s was not enabled.') % @to_enable.name
      end
      redirect_to :action => 'index'
    end
  end

  def disable
    @to_disable = profile
    if request.post? && params[:confirmation]
      unless @to_disable.update_attribute('enabled', false)
        session[:notice] = _('%s was not disabled.') % @to_disable.name
      end
      redirect_to :action => 'index'
    end
  end

  def header_footer
    @no_design_blocks = true
    if request.post?
      @profile.update_header_and_footer(params[:custom_header], params[:custom_footer])
      redirect_to :action => 'index'
    else
      @header = boxes_holder.custom_header
      @footer = boxes_holder.custom_footer
    end
  end

  def destroy_profile
    if request.post?
      if @profile.destroy
        session[:notice] = _('The profile was deleted.')
        if(params[:return_to])
          redirect_to url_for(params[:return_to])
        else
          redirect_to :controller => 'home'
        end
      else
        session[:notice] = _('Could not delete profile')
      end
    end
  end

  def welcome_page
    @welcome_page = profile.welcome_page || TextArticle.new(:name => 'Welcome Page', :profile => profile, :published => false)
    if request.post?
      begin
        @welcome_page.update!(params[:welcome_page])
        profile.welcome_page = @welcome_page
        profile.save!
        session[:notice] = _('Welcome page saved successfully.')
        redirect_to :action => 'index'
      rescue Exception => exception
        session[:notice] = _('Welcome page could not be saved.')
      end
    end
  end

  def deactivate_profile
    if environment.admins.include?(current_person)
      profile = environment.profiles.find(params[:id])
      if profile.disable
        profile.save
        session[:notice] = _("The profile '%s' was deactivated.") % profile.name
      else
        session[:notice] = _('Could not deactivate profile.')
      end
    end

    redirect_to_previous_location
  end

  def activate_profile
    if environment.admins.include?(current_person)
      profile = environment.profiles.find(params[:id])

      if profile.enable
        session[:notice] = _("The profile '%s' was activated.") % profile.name
      else
        session[:notice] = _('Could not activate the profile.')
      end
    end

    redirect_to_previous_location
  end

  def reset_private_token
    profile = environment.profiles.find(params[:id])
    profile.user.generate_private_token!

    redirect_to_previous_location
  end

  protected

  def redirect_to_previous_location
    redirect_to @back_to
  end

  #TODO Consider using this as a general controller feature to be available on every action.
  def back_to
    @back_to = params[:back_to] || request.referer || "/"
  end

  private

  def update_profile_data
    @profile_data = profile
    if request.post?
      begin
        @profile_data.update!(params[:profile_data])
        redirect_to :action => 'index', :profile => profile.identifier
        session[:notice] = _('Changes applied correctly')
      rescue
        profile.identifier = params[:profile] if profile.identifier.blank?
        session[:notice] = _('Something wrong happened! Changes could not be save!')
      end
    end
  end

  def has_welcome_page
    profile.is_template
  end

  def access_welcome_page
    unless has_welcome_page
      render_access_denied
    end
  end

  def forbid_destroy_profile
    if environment.enabled?('forbid_destroy_profile') && !current_person.is_admin?(environment)
      session[:notice] = _('You can not destroy the profile.')
      redirect_to_previous_location
    end
  end

  def check_user_can_edit_header_footer
    user_can_not_edit_header_footer = !user.is_admin?(environment) && environment.enabled?('disable_header_and_footer')
    redirect_to back_to if user_can_not_edit_header_footer
  end

  def location_active
    unless (profile.active_fields & Profile::LOCATION_FIELDS).present? ||
           profile.active_fields.include?('location')
      session[:notice] = _('Location is disabled on the environment.')
      redirect_to action: 'index'
    end
  end
end
