class PeopleBlockPluginProfileController < ProfileController

  append_view_path File.join(File.dirname(__FILE__) + '/../views')

  def members
    if is_cache_expired?(profile.members_cache_key(params))
      unless params[:role_key].blank?
        role = Role.find_by_key_and_environment_id(params[:role_key], profile.environment)
        @members = profile.members.with_role(role.id)
        @members_title = role.name
      else
        @members = profile.members
        @members_title = 'members'
      end
      @members = @members.includes(relations_to_include).paginate(:per_page => members_per_page, :page => params[:npage], :total_entries => @members.count)
    end
    render "profile/members"
  end

end
