class ProfileEditorController < MyProfileController

  protect 'edit_profile', :profile, :except => [:destroy_profile]
  protect 'destroy_profile', :profile, :only => [:destroy_profile]

  before_filter :access_welcome_page, :only => [:welcome_page]
  before_filter :back_to
  before_filter :forbid_destroy_profile, :only => [:destroy_profile]
  helper_method :has_welcome_page

  def index
    @pending_tasks = Task.to(profile).pending.without_spam.select{|i| user.has_permission?(i.permission, profile)}
  end

  helper :profile

  # edits the profile info (posts back)
  def edit
    @profile_data = profile
    @possible_domains = profile.possible_domains
    if request.post?
      params[:profile_data][:fields_privacy] ||= {} if profile.person? && params[:profile_data].is_a?(Hash)
      Profile.transaction do
        Image.transaction do
          begin
            @plugins.dispatch(:profile_editor_transaction_extras)
            @profile_data.update_attributes!(params[:profile_data])
            redirect_to :action => 'index', :profile => profile.identifier
          rescue Exception => ex
            profile.identifier = params[:profile] if profile.identifier.blank?
          end
        end
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

  def update_categories
    @object = profile
    @categories = @toplevel_categories = environment.top_level_categories
    if params[:category_id]
      @current_category = Category.find(params[:category_id])
      @categories = @current_category.children
    end
    render :template => 'shared/update_categories', :locals => { :category => @current_category, :object_name => 'profile_data' }
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
          redirect_to params[:return_to]
        else
          redirect_to :controller => 'home'
        end
      else
        session[:notice] = _('Could not delete profile')
      end
    end
  end

  def welcome_page
    @welcome_page = profile.welcome_page || TinyMceArticle.new(:name => 'Welcome Page', :profile => profile, :published => false)
    if request.post?
      begin
        @welcome_page.update_attributes!(params[:welcome_page])
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
end
