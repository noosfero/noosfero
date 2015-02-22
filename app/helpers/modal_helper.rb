module ModalHelper

  def modal_inline_link_to title, url, selector, options = {}
    link_to title, url, modal_options(options.merge(:inline => selector))
  end

  def modal_inline_icon type, title, url, selector, options = {}
    icon_button type, title, url, modal_options(options.merge(:inline => selector))
  end

  def modal_link_to title, url, options = {}
    link_to title, url, modal_options(options)
  end

  def modal_close_link text, options = {}
    link_to text, '#', modal_options(options, :close)
  end

  def modal_close_button(text, options = {})
    button :close, text, '#', modal_options(options, :close).merge(:rel => 'deactivate')
  end

  def modal_button(type, label, url, options = {})
    button type, label, url, modal_options(options)
  end

  def modal_icon_button(type, label, url, options = {})
    icon_button type, label, url, modal_options(options)
  end

  # options must be an HTML options hash as passed to link_to etc.
  #
  # returns a new hash with modal class added. Keeps existing classes.
  def modal_options(options, type=nil)
    inline_selector = options.delete :inline
    options[:onclick] = "return noosfero.modal.inline('#{inline_selector}')" if inline_selector

    classes = if inline_selector then '' else 'modal-toggle' end
    classes += " modal-#{type.to_s}" if type.present?
    classes << " #{options[:class]}" if options.has_key? :class
    options.merge!(:class => classes)

    options
  end

end
