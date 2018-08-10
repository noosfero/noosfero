class FriendsBlock < PeopleBlockBase

  def self.description
    c_('Friends')
  end

  def help
    _('Clicking a friend takes you to his/her homepage')
  end

  def default_title
    return _('friends') if profile_count == 0
    n_('{#} friend', '{#} friends', profile_count)
  end

  def base_profiles
    owner.friends
  end

  def profiles(user=nil)
    profiles = super
    profiles.order('RANDOM()')
  end

  def suggestions
    owner.suggested_profiles.of_person.enabled.limit(3).includes(:suggestion)
  end

  def self.expire_on
    { :profile => [:profile] }
  end

end
