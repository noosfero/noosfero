module LightboxHelper

  def include_lightbox_header
    stylesheet_link_tag('lightbox') + javascript_include_tag('lightbox')
  end

  def lightbox_link_to(text, url, options = {})
    the_class = 'lbOn'
    the_class << " #{options[:class]}" if options.has_key?(:class)
    link_to(text, url, options.merge(:class => the_class ))
  end

  def lightbox_close(text, options = {})
    the_class = 'lbAction'
    the_class << " #{options[:class]}" if options.has_key?(:class)
    link_to(text, '#', options.merge({ :class => the_class, :rel => 'deactivate' }))
  end

end
