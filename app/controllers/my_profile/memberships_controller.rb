class MembershipsController < MyProfileController

  protect 'manage_memberships', :profile

  def index
    @roles = environment.roles.select{ |role| profile.role_assignments.find_by_role_id(role.id).present? }
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
    if request.post? && @community.valid?
      @community = Community.create_after_moderation(user, {:environment => environment}.merge(params[:community]))
      redirect_to :action => 'index'
      return
    end
  end
end
