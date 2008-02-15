class CommunitiesBlock < ProfileListBlock

  def self.description
    _('A block that displays your communities')
  end

  def title
    _('Communities')
  end

  def profile_finder
    @profile_finder ||= CommunitiesBlock::Finder.new(self)
  end

  class Finder < ProfileListBlock::Finder
    def find
      ids = block.owner.community_memberships.map(&:id)
      result = []
      [block.limit, ids.size].min.times do
        i = pick_random(ids.size)
        result << Profile.find(ids[i])
        ids.delete_at(i)
      end
      result
    end
  end

end
