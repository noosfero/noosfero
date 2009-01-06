module DisplayHelper

  def link_to_product(product, opts={})
    return _('No product') unless product
    target = product.enterprise.enabled? ? product.enterprise.generate_url(:controller => 'catalog', :action => 'show', :id => product) : 'javascript: void(0);'
    link_to content_tag( 'span', product.name ),
            target,
            opts
  end

  def link_to_category(category, full = true)
    return _('Uncategorized product') unless category
    name = full ? category.full_name(' &rarr; ') : category.name
    link_to name, Noosfero.url_options.merge({:controller => 'search', :action => 'category_index', :category_path => category.path.split('/'),:host => category.environment.default_hostname })
  end

  def txt2html(txt)
    txt.
      gsub( /\n\s*\n/, ' <p/> ' ).
      gsub( /\n/, ' <br/> ' ).
      gsub( /(^|\s)(www\.[^\s])/, '\1http://\2' ).
      gsub( /(https?:\/\/([^\s]+))/,
            '<a href="\1" target="_blank" rel="nofolow" onclick="return confirm(\'' +
            escape_javascript( _('Are you sure you want to visit this web site?') ) +
            '\n\n\'+this.href)">\2</a>' )
  end
end
