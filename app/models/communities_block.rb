class CommunitiesBlock < ProfileListBlock

  def self.description
    __('Communities')
  end

  def default_title
    n__('{#} community', '{#} communities', profile_count)
  end

  def help
    __('This block displays the communities in which the user is a member.')
  end

  def footer
    owner = self.owner
    case owner
    when Profile
      lambda do
        link_to s_('communities|View all'), :profile => owner.identifier, :controller => 'profile', :action => 'communities'
      end
    when Environment
      lambda do
        link_to s_('communities|View all'), :controller => 'browse', :action => 'communities'
      end
    else
      ''
    end
  end

  def profiles
    owner.communities
  end

end
