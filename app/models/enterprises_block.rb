class EnterprisesBlock < ProfileListBlock

  def title
    _('Enterprises')
  end

  def self.description
    _('A block that displays your enterprises')
  end

  def footer
    profile = self.owner
    lambda do
      link_to _('All enterprises'), :profile => profile.identifier, :controller => 'profile', :action => 'enterprises'
    end
  end


  def profile_finder
    @profile_finder ||= EnterprisesBlock::Finder.new(self)
  end

  class Finder < ProfileListBlock::Finder
    def ids
      block.owner.enterprise_memberships.map(&:id)
    end
  end

end
