module DisplayHelper

  def themed_path(file)
    if File.exists?(File.join(Rails.root, 'public', theme_path, file))
      File.join(theme_path, file)
    else
      file
    end
  end

  def price_span(price, options = {})
    content_tag 'span',
      number_to_currency(price, :unit => environment.currency_unit, :delimiter => environment.currency_delimiter, :separator => environment.currency_separator),
      options
  end

  def link_to_tag(tag, html_options = {})
    link_to tag.name, {:controller => 'search', :action => 'tag', :tag => tag.name}, html_options
  end

  def link_to_category(category, full = true, html_options = {})
    name = full ? category.full_name(' &rarr; ') : category.name
    link_to name, Noosfero.url_options.merge({:controller => 'search', :action => 'category_index', :category_path => category.path.split('/'),:host => category.environment.default_hostname }), html_options
  end

  def txt2html(txt)
    ret = txt.strip.
      gsub( /\s*\n\s*\n\s*/, "\r<p/>\r" ).
      gsub( /\s*\n\s*/, "\n<br/>\n" ).
      gsub( /\r/, "\n" ).
      gsub( /(^|\s)(www\.[^\s]+|https?:\/\/[^\s]+)/ ) do
        pre_char, href = $1, $2
        href = 'http://'+href  if ! href.match /^https?:/
        content = safe_join(href.gsub(/^https?:\/\//, '').scan(/.{1,4}/), '&#x200B;'.html_safe)
        pre_char +
        content_tag(:a, content, :href => href, :target => '_blank',
                    :rel => 'nofolow', :onclick => "return confirm('%s')".html_safe %
                      _('Are you sure you want to visit this web site?'))
      end
      ret.html_safe
  end
end
