class ProductsBlock < Block

  attr_accessible :product_ids

  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers
  include Rails.application.routes.url_helpers

  def self.description
    _('Products')
  end

  def default_title
    _('Products')
  end

  def help
    _('This block presents a list of your products.')
  end

  settings_items :product_ids, type: Array
  def product_ids=(array)
    self.settings[:product_ids] = array
    if self.settings[:product_ids]
      self.settings[:product_ids] = self.settings[:product_ids].map(&:to_i)
    end
  end

  def products(reload = false)
    if product_ids.blank?
      owner.products.order('RANDOM()').limit([4,owner.products.count].min)
    else
      owner.products.where(:id => product_ids)
    end.compact
  end

end
