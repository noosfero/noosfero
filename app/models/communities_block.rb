class CommunitiesBlock < ProfileListBlock

  attr_accessible :accessor_id, :accessor_type, :role_id, :resource_id, :resource_type

  def self.description
    _('Communities')
  end

  def default_title
    n_('{#} community', '{#} communities', profile_count)
  end

  def help
    _('This block displays the communities in which the user is a member.')
  end

  def footer
    owner = self.owner
    case owner
    when Profile
      lambda do |context|
        link_to s_('communities|View all'), :profile => owner.identifier, :controller => 'profile', :action => 'communities'
      end
    when Environment
      lambda do |context|
        link_to s_('communities|View all'), :controller => 'search', :action => 'communities'
      end
    else
      ''
    end
  end

  def profiles
    owner.communities
  end

end
