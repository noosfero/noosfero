class MembersBlock < ProfileListBlock

  def self.description
    _('Members')
  end

  def default_title
    _('{#} members')
  end

  def help
    _('This block presents the members of a collective.')
  end

  def footer
    profile = self.owner
    lambda do
      link_to _('View all'), :profile => profile.identifier, :controller => 'profile', :action => 'members'
    end
  end

  def profiles
    owner.members
  end

end
