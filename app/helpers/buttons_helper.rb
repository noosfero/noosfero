module ButtonsHelper
  def button(type, label, url, html_options = {})
    html_options ||= {}
    the_class = 'with-text'
    if html_options.has_key?(:class)
      the_class << ' ' << html_options[:class]
    end
    button_without_text type, label, url, html_options.merge(:class => the_class)
  end

  def button_without_text(type, label, url, html_options = {})
    the_class = "button icon-#{type}"
    if html_options.has_key?(:class)
      the_class << ' ' << html_options[:class]
    end
    the_title = html_options[:title] || label
    if html_options[:disabled]
      content_tag('a', '&nbsp;'+content_tag('span', label), html_options.merge(:class => the_class, :title => the_title))
    else
      link_to('&nbsp;'+content_tag('span', label), url, html_options.merge(:class => the_class, :title => the_title))
    end
  end

  def button_to_function(type, label, js_code, html_options = {}, &block)
    html_options[:class] = "button with-text" unless html_options[:class]
    html_options[:class] << " icon-#{type}"
    link_to_function(label, js_code, html_options, &block)
  end

  def button_to_function_without_text(type, label, js_code, html_options = {}, &block)
    html_options[:class] = "" unless html_options[:class]
    html_options[:class] << " button icon-#{type}"
    link_to_function(content_tag('span', label), js_code, html_options, &block)
  end

  def button_to_remote(type, label, options, html_options = {})
    html_options[:class] = "button with-text" unless html_options[:class]
    html_options[:class] << " icon-#{type}"
    link_to_remote(label, options, html_options)
  end

  def button_to_remote_without_text(type, label, options, html_options = {})
    html_options[:class] = "" unless html_options[:class]
    html_options[:class] << " button icon-#{type}"
    link_to_remote(content_tag('span', label), options, html_options.merge(:title => label))
  end
end
