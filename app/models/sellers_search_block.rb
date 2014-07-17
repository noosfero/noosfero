class SellersSearchBlock < Block

  attr_accessible :title

  def self.description
    _('Search for enterprises and products')
  end

  def self.short_description
    _('Products/Enterprises search')
  end

  def default_title
    _('Search for sellers')
  end

  def help
    _('This block presents a search engine for products.')
  end

  def content(args={})
    title = self.title
    lambda do |object|
      render :file => 'search/_sellers_form', :locals => { :title => title }
    end
  end
end
