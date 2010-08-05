class SellersSearchBlock < Block

  def self.description
    __('A search for enterprises by products selled and local')
  end

  def self.short_description
    __('Products/Enterprises search')
  end

  def default_title
    _('Search for sellers')
  end

  def help
    _('This block presents a search engine for products.')
  end

  def content
    title = self.title
    lambda do
      render :file => 'search/_sellers_form', :locals => { :title => title }
    end
  end
end
