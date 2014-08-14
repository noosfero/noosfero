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

  def content(args={})
    block_title(title) +
    content_tag(
      'ul',
      products.map {|product|
        content_tag('li',
          link_to( product.name,
                   product.url,
                   :style => 'background-image:url(%s)' % product.default_image('minor')
                 ),
          :class => 'product'
        )
      }.join
    )
  end

  def footer
    link_to(_('View all products'), owner.public_profile_url.merge(:controller => 'catalog', :action => 'index'))
  end

  settings_items :product_ids, Array
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
