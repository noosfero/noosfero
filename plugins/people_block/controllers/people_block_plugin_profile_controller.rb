class PeopleBlockPluginProfileController < ProfileController

  append_view_path File.join(File.dirname(__FILE__) + '/../views')

  def members
    if is_cache_expired?(profile.members_cache_key(params))
      if(params[:role_key])
        role = Role.find_by_key_and_environment_id(params[:role_key], profile.environment)
        @members = profile.members.with_role(role.id).includes(relations_to_include).paginate(:per_page => members_per_page, :page => params[:npage])
        @members_title = role.name
      else
        @members = profile.members.includes(relations_to_include).paginate(:per_page => members_per_page, :page => params[:npage])
        @members_title = 'members'
      end
    end
    render "profile/members"
  end

end
