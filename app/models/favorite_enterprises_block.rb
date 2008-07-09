class FavoriteEnterprisesBlock < ProfileListBlock

  def default_title
    _('Favorite Enterprises')
  end

  def help
    _('This user\'s favorite enterprises.')
  end

  def self.description
    _('A block that displays your favorite enterprises')
  end

  def footer
    owner = self.owner
    return '' unless owner.kind_of?(Person)
    lambda do
      link_to _('All favorite enterprises'), :profile => owner.identifier, :controller => 'profile', :action => 'favorite_enterprises'
    end
  end


  def profile_finder
    @profile_finder ||= FavoriteEnterprisesBlock::Finder.new(self)
  end

  class Finder < ProfileListBlock::Finder
    def ids
      block.owner.favorite_enterprises.map(&:id)
    end
  end

end
