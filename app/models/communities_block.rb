class CommunitiesBlock < ProfileListBlock

  def self.description
    _('A block that displays your communities')
  end

  def default_title
    _('Communities')
  end

  def help
    _('The communities in which the user is a member')
  end

  def footer
    owner = self.owner
    case owner
    when Profile
      lambda do
        link_to _('All communities'), :profile => owner.identifier, :controller => 'profile', :action => 'communities'
      end
    when Environment
      lambda do
        link_to _('All communities'), :controller => 'search', :action => 'assets', :asset => 'communities'
      end
    else
      ''
    end
  end

  def profile_finder
    @profile_finder ||= CommunitiesBlock::Finder.new(self)
  end

  class Finder < ProfileListBlock::Finder
    def ids
      # FIXME when owner is an environment (i.e. listing communities globally
      # this can become SLOW)
      block.owner.communities.select(&:public_profile).map(&:id)
    end
  end

end
