class MembersBlock < PeopleBlockBase

  def self.description
    _('Members')
  end

  def help
    _('Clicking a member takes you to his/her homepage')
  end

  def default_title
    _('{#} Members')
  end

  def profiles
    owner.members
  end

  def footer
    owner = self.owner
    lambda do
      link_to _('View all'), :profile => owner.identifier, :controller => 'profile', :action => 'members'
    end
  end

end

