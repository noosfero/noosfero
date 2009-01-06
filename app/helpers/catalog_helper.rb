module CatalogHelper

include DisplayHelper

  def display_products_list(profile, products)
    data = ''
    products.each { |product|

      data << content_tag('li',
        link_to_product(product, :class => 'product-pic', :style => 'background-image:url(%s)' % ( product.image ? product.image.public_filename(:portrait) : '/images/icons-app/product-default-pic-portrait.png' )) +
        content_tag('h3', link_to_product(product)) +
        content_tag('ul',
          (product.price ? content_tag('li', _('Price: %s') % ( "%.2f" % product.price), :class => 'product_price') : '') +
          content_tag('li', profile.enabled? ? link_to_category(product.product_category) : product.product_category, :class => 'product_category')
        ) +
        (product.description ? content_tag('div', txt2html(product.description), :class => 'description') : tag('br', :style => 'clear:both')),
        :class => 'product')
    }
    content_tag('h1', _('Products/Services')) + content_tag('ul', data, :id => 'product_list')
  end
end
