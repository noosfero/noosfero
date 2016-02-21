class MembershipsController < MyProfileController

  protect 'manage_memberships', :profile
  helper CustomFieldsHelper

  def index
    @roles = environment.roles.select do |role|
      ra = profile.role_assignments.find_by(role_id: role.id)
      ra.present? && ra.resource_type == 'Profile'
    end
    @filter = params[:filter_type].to_i
    begin
      @memberships = @filter.zero? ? profile.memberships : profile.memberships_by_role(environment.roles.find(@filter))
    rescue ActiveRecord::RecordNotFound
      @memberships = []
    end
  end

  def new_community
    @community = Community.new(params[:community])
    custom_values = params[:profile_data][:custom_values] if (params[:profile_data] && params[:profile_data][:custom_values])
    @community.custom_values = custom_values
    @community.environment = environment
    @back_to = params[:back_to] || url_for(:action => 'index')
    if request.post? && @community.valid?
      begin
        # Community was created
        @community = Community.create_after_moderation(user, params[:community].merge({:environment => environment, :custom_values => custom_values}))
        @community.reload
        redirect_to :action => 'welcome', :community_id => @community.id, :back_to => @back_to
      rescue ActiveRecord::RecordNotFound
        # Community pending approval
        session[:notice] = _('Your new community creation request will be evaluated by an administrator. You will be notified.')
        redirect_to @back_to
      end
      return
    end
  end

  def welcome
    @community = Community.find(params[:community_id])
    @back_to = params[:back_to]
  end

  def suggest
    @suggestions = profile.suggested_profiles.of_community.enabled.includes(:suggestion).limit(per_page)
  end

  def remove_suggestion
    @community = profile.suggested_communities.find_by(identifier: params[:id])
    custom_per_page = params[:per_page] || per_page
    redirect_to :action => 'suggest' unless @community
    if @community && request.post?
      profile.remove_suggestion(@community)
      @suggestions = profile.suggested_profiles.of_community.enabled.includes(:suggestion).limit(custom_per_page)
      render :partial => 'shared/profile_suggestions_list', :locals => { :suggestions => @suggestions, :collection => :communities_suggestions, :per_page => custom_per_page}
    end
  end

  def connections
    @suggestion = profile.suggested_profiles.of_community.enabled.find_by(suggestion_id: params[:id])
    if @suggestion
      @tags = @suggestion.tag_connections
      @profiles = @suggestion.profile_connections
    else
      redirect_to :action => 'suggest'
    end
  end

  protected

  def per_page
    12
  end

end
