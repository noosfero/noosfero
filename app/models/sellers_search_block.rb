class SellersSearchBlock < Block

  def self.description
    __('A search for enterprises by products selled and local')
  end

  def self.short_description
    _('Sellers search block')
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
      @categories = ProductCategory.find(:all)
      @regions = Region.find(:all).select{|r|r.lat && r.lng}
      render :file => 'search/_sellers_form', :locals => { :title => title }
    end
  end
end
