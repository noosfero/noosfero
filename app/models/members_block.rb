class MembersBlock < ProfileListBlock

  def self.description
    _('A block that displays members.')
  end

  def title
    _('Members')
  end

  def footer
    profile = self.owner
    lambda do
      link_to _('View all'), :profile => profile.identifier, :controller => 'profile', :action => 'members'
    end
  end

  def profile_finder
    @profile_finder ||= MembersBlock::Finder.new(self)
  end

  # Finds random members, up to the limit.
  class Finder < ProfileListBlock::Finder
    def ids
      block.owner.members.map(&:id)
    end
  end


end
