class CommunitiesBlock < ProfileListBlock

  def self.description
    _('A block that displays your communities')
  end

  def title
    _('Communities')
  end

  def help
    _('The communities in which the user is a member')
  end

  def footer
    profile = self.owner
    lambda do
      link_to _('All communities'), :profile => profile.identifier, :controller => 'profile', :action => 'communities'
    end
  end

  def profile_finder
    @profile_finder ||= CommunitiesBlock::Finder.new(self)
  end

  class Finder < ProfileListBlock::Finder
    def ids
      block.owner.community_memberships.map(&:id)
    end
  end

end
