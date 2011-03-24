module DisplayHelper

  def link_to_product(product, opts={})
    return _('No product') unless product
    target = product_path(product)
    link_to content_tag( 'span', product.name ),
            target,
            opts
  end

  def product_path(product)
    product.enterprise.enabled? ? product.enterprise.public_profile_url.merge(:controller => 'manage_products', :action => 'show', :id => product) : product.enterprise.url
  end

  def link_to_category(category, full = true)
    return _('Uncategorized product') unless category
    name = full ? category.full_name(' &rarr; ') : category.name
    link_to name, Noosfero.url_options.merge({:controller => 'search', :action => 'category_index', :category_path => category.path.split('/'),:host => category.environment.default_hostname })
  end

  def link_to_product_category(category)
    if category
      link_to(category.name, :controller => 'search', :action => 'assets', :asset => 'products', :product_category => category.id, :host => category.environment.default_hostname)
    else
      _('Uncategorized product')
    end
  end

  def txt2html(txt)
    txt.strip.
      gsub( /\s*\n\s*\n\s*/, "\r<p/>\r" ).
      gsub( /\s*\n\s*/, "\n<br/>\n" ).
      gsub( /\r/, "\n" ).
      gsub( /(^|\s)(www\.[^\s]+|https?:\/\/[^\s]+)/ ) do
        pre_char, href = $1, $2
        href = 'http://'+href  if ! href.match /^https?:/
        content = href.gsub(/^https?:\/\//, '').scan(/.{1,4}/).join('&#x200B;')
        pre_char +
        content_tag(:a, content, :href => href, :target => '_blank',
                    :rel => 'nofolow', :onclick => "return confirm('%s')" %
                      _('Are you sure you want to visit this web site?'))
      end
  end
end
