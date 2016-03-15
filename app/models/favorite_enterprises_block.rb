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

  def profiles
    owner.favorite_enterprises
  end

end
