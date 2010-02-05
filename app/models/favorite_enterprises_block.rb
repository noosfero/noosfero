class FavoriteEnterprisesBlock < ProfileListBlock

  def default_title
    __('Favorite Enterprises')
  end

  def help
    __('This block lists your favorite enterprises.')
  end

  def self.description
    __('Favorite enterprises')
  end

  def footer
    owner = self.owner
    return '' unless owner.kind_of?(Person)
    lambda do
      link_to __('View all'), :profile => owner.identifier, :controller => 'profile', :action => 'favorite_enterprises'
    end
  end

  def profile_count
    owner.favorite_enterprises.count
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
