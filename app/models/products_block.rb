class ProductsBlock < Block

  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::UrlHelper
  include ActionController::UrlWriter

  def content
    block_title(_('Products')) +
    content_tag(
      'ul',
      owner.products.map {|product| content_tag('li', link_to(product.name, product.url), :class => 'product', :style => 'background-image:url(%s)' % ( product.image ? product.image.public_filename(:minor) : '/images/icons-app/product-default-pic-minor.png' ) )}
    )
  end

end
