module ColorboxHelper

  def colorbox_inline_link_to title, url, selector, options = {}
    link_to title, url, colorbox_options(options.merge(:inline => selector))
  end

  def colorbox_inline_icon type, title, url, selector, options = {}
    icon_button type, title, url, colorbox_options(options.merge(:inline => selector))
  end

  def colorbox_link_to title, url, options = {}
    link_to title, url, colorbox_options(options)
  end

  def colorbox_close_link text, options = {}
    link_to text, '#', colorbox_options(options, :close)
  end

  def colorbox_close_button(text, options = {})
    button(:close, text, '#', colorbox_options(options, :close))
  end

  def colorbox_button(type, label, url, options = {})
    button(type, label, url, colorbox_options(options))
  end

  def colorbox_icon_button(type, label, url, options = {})
    icon_button(type, label, url, colorbox_options(options))
  end

  # options must be an HTML options hash as passed to link_to etc.
  #
  # returns a new hash with colorbox class added. Keeps existing classes.
  def colorbox_options(options, type=nil)
    inline_selector = options.delete :inline
    options[:onclick] = "return colorbox_helpers.inline('#{inline_selector}')" if inline_selector

    classes = if inline_selector then '' else 'colorbox' end
    classes += "-#{type.to_s}" if type.present?
    classes << " #{options[:class]}" if options.has_key? :class
    options.merge!(:class => classes)

    options
  end

end
