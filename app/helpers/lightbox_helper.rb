module LightboxHelper

  def lightbox_link_to(text, url, options = {})
    link_to(text, url, lightbox_options(options))
  end

  def lightbox_close_button(text, options = {})
    button(:close, text, '#', lightbox_options(options, 'lbAction').merge(:rel => 'deactivate'))
  end

  def lightbox_button(type, label, url, options = {})
    button(type, label, url, lightbox_options(options))
  end

  def lightbox_icon_button(type, label, url, options = {})
    icon_button(type, label, url, lightbox_options(options))
  end

  # options must be an HTML options hash as passed to link_to etc.
  #
  # returns a new hash with lightbox class added. Keeps existing classes. 
  def lightbox_options(options, lightbox_type = 'lbOn')
    the_class = lightbox_type
    the_class << " #{options[:class]}" if options.has_key?(:class)
    options.merge(
      :class => the_class,
      :onclick => 'alert("%s"); return false' % _('Please, try again when the page loading completes.')
    )
  end

  def lightbox?
    request.xhr?
  end

  def lightbox_remote_button(type, label, url, options = {})
    button(type, label, url, lightbox_options(options, 'remote-lbOn'))
  end

end
