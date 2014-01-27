class FavoriteEnterprisesBlock < ProfileListBlock

  def default_title
    _('Favorite Enterprises')
  end

  def help
    _('This block lists your favorite enterprises.')
  end

  def self.description
    _('Favorite Enterprises')
  end

  def footer
    owner = self.owner
    return '' unless owner.kind_of?(Person)
    proc do
      link_to _('View all'), :profile => owner.identifier, :controller => 'profile', :action => 'favorite_enterprises'
    end
  end

  def profiles
    owner.favorite_enterprises
  end

end
