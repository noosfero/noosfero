class FriendsBlock < PeopleBlockBase

  def self.description
    _('Friends')
  end

  def help
    _('Clicking a friend takes you to his/her homepage')
  end

  def default_title
    n_('{#} friend', '{#} friends', profile_count)
  end

  def profiles
    owner.friends
  end

  def footer
    profile = self.owner
    proc do
      render :file => 'blocks/friends', :locals => { :profile => profile }
    end
  end

  def self.expire_on
    { :profile => [:profile] }
  end

end
