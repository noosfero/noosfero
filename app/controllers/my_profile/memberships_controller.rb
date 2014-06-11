class MembershipsController < MyProfileController

  protect 'manage_memberships', :profile

  def index
    @roles = environment.roles.select do |role|
      ra = profile.role_assignments.find_by_role_id(role.id)
      ra.present? && ra.resource_type == 'Profile'
    end
    @filter = params[:filter_type].blank? ? nil : params[:filter_type]
    begin
      @memberships = @filter.nil? ? profile.memberships : profile.memberships_by_role(environment.roles.find(@filter))
    rescue ActiveRecord::RecordNotFound
      @memberships = []
    end
  end

  def new_community
    @community = Community.new(params[:community])
    @community.environment = environment
    @back_to = params[:back_to] || url_for(:action => 'index')
    if request.post? && @community.valid?
      begin
        # Community was created
        @community = Community.create_after_moderation(user, params[:community].merge({:environment => environment}))
        @community.reload
        redirect_to :action => 'welcome', :community_id => @community.id, :back_to => @back_to
      rescue ActiveRecord::RecordNotFound
        # Community pending approval
        session[:notice] = _('Your community creation request is waiting approval of the administrator.')
        redirect_to @back_to
      end
      return
    end
  end

  def welcome
    @community = Community.find(params[:community_id])
    @back_to = params[:back_to]
  end
end
