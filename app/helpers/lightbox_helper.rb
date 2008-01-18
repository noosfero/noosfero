module LightboxHelper

  def include_lightbox_header
    stylesheet_link_tag('lightbox') + javascript_include_tag('lightbox')
  end

  def lightbox_link_to(text, url, options = {})
    link_to(text, url, lightbox_options(options))
  end

  def lightbox_close(text, options = {})
    button(:close, text, '#', lightbox_options(options, 'lbAction').merge(:rel => 'deactivate'))
  end

  def lightbox_button(type, label, url, options = {})
    button(type, label, url, lightbox_options(options))
  end

  # options must be an HTML options hash as passed to link_to etc.
  #
  # returns a new hash with lightbox class added. Keeps existing classes. 
  def lightbox_options(options, lightbox_type = 'lbOn')
    the_class = lightbox_type
    the_class << " #{options[:class]}" if options.has_key?(:class)
    options.merge(:class => the_class)
  end

end
