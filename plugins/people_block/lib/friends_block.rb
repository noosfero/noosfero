class FriendsBlock < PeopleBlockBase

  def self.description
    _('Friends')
  end

  def help
    _('Clicking a friend takes you to his/her homepage')
  end

  def default_title
    _('{#} Friends')
  end

  def profiles
    owner.friends
  end

  def footer
    owner = self.owner
    proc do
      link_to _('View all'), :profile => owner.identifier, :controller => 'profile', :action => 'friends'
    end
  end

  def self.expire_on
    { :profile => [:profile] }
  end

end

