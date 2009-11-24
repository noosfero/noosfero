class FriendsBlock < ProfileListBlock

  def self.description
    __('A block that displays your friends')
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

  class FriendsBlock::Finder < ProfileListBlock::Finder
    def ids
      self.block.owner.friend_ids
    end
  end

  def profile_finder
    @profile_finder ||= FriendsBlock::Finder.new(self)
  end

  def profile_count
    owner.friends.count(:conditions => { :public_profile => true })
  end

end
