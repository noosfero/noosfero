class FriendsBlock < ProfileListBlock

  def self.description
    __('Friends')
  end

  def default_title
    n__('{#} friend', '{#} friends', profile_count)
  end

  def help
    _('This block displays your friends.')
  end

  def footer
    owner_id = owner.identifier
    lambda do
      link_to s_('friends|View all'), :profile => owner_id, :controller => 'profile', :action => 'friends'
    end
  end

  def profiles
    owner.friends
  end

end
