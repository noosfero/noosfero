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
      link_to _('All members'), :profile => profile.identifier, :controller => 'profile', :action => 'members'
    end
  end

  def profile_finder
    @profile_finder ||= MembersBlock::Finder.new(self)
  end

  # Finds random members, up to the limit.
  class Finder
    def initialize(block)
      @block = block
    end
    attr_reader :block

    def find
      ids = block.owner.members.map(&:id)
      result = []
      [block.limit, ids.size].min.times do
        i = pick_random(ids.size)
        result << Profile.find(ids[i])
        ids.delete_at(i)
      end
      result
    end

    def pick_random(top)
      rand(top)
    end

  end


end
