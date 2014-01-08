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
      @community = Community.create_after_moderation(user, params[:community].merge({:environment => environment}))
      redirect_to @back_to
      return
    end
  end
end
