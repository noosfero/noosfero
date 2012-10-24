module ColorboxHelper

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
    the_class = 'colorbox'
    the_class += "-#{type.to_s}" unless type.nil?
    the_class << " #{options[:class]}" if options.has_key?(:class)
    options.merge(:class => the_class)
  end

end
