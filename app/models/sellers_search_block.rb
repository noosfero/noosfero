class SellersSearchBlock < Block

  attr_accessible :title

  def self.description
    _('Search for enterprises and products')
  end

  def self.short_description
    _('Products/Enterprises search')
  end

  def self.pretty_name
    _('Sellers Search')
  end

  def default_title
    _('Search for sellers')
  end

  def help
    _('This block presents a search engine for products.')
  end

end
