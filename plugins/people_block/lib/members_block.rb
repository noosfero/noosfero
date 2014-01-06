class MembersBlock < PeopleBlockBase

  settings_items :visible_role, :type => :string, :default => nil

  def self.description
    _('Members')
  end

  def help
    _('Clicking a member takes you to his/her homepage')
  end

  def default_title
    title = role ? role.name : 'Members'
    _('{#} %s') % title
  end

  def profiles
    role ? owner.members.with_role(role.id) : owner.members
  end

  def footer
    owner = self.owner
    role_key = visible_role
    lambda do
      link_to _('View all'), :profile => owner.identifier, :controller => 'people_block_plugin_profile', :action => 'members', :role_key => role_key
    end
  end

  def role
    visible_role && !visible_role.empty? ? Role.find_by_key_and_environment_id(visible_role, owner.environment) : nil
  end

  def roles
    Profile::Roles.organization_member_roles(owner.environment)
  end

end

