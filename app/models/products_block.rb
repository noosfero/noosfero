class ProductsBlock < Block

  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::UrlHelper
  include ActionController::UrlWriter

  def content
    block_title(_('Products')) +
    content_tag(
      'ul',
      owner.products.map {|product| content_tag('li', link_to(product.name, product.url, :style => 'background-image:url(%s)' % ( product.image ? product.image.public_filename(:minor) : '/images/icons-app/product-default-pic-minor.png' )), :class => 'product' )}
    )
  end

  def footer
    link_to(_('View all'), owner.generate_url(:controller => 'catalog', :action => 'index'))
  end

  settings_items :product_ids, Array

  def products(reload = false)
    if product_ids.blank?
      products_list = owner.products(reload)
      result = []
      [4, products_list.size].min.times do
        result << products_list.rand
      end
      result
    else
      product_ids.map {|item| owner.products.find(item) }
    end
  end

end
