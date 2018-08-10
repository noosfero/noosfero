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

  def base_profiles
    owner.favorite_enterprises
  end

  def self.pretty_name
      _('Favorite Enterprises')
  end

  private

  def base_class
    Enterprise
  end

end
