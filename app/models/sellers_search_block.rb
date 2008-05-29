class SellersSearchBlock < Block

  def self.description
    _('A search for enterprises by products selled and local')
  end

  def content
    lambda do
      @categories = ProductCategory.find(:all)
      @regions = Region.find(:all).select{|r|r.lat && r.lng}
      render :file => 'search/_sellers_form'
    end
  end
end
