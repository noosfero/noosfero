module ButtonsHelper

  def font_awesome type, label = ""
    noosfero_to_fontawesome = { back: "arrow-left", new: "plus", save_and_continue: "cloud-upload",
                                cancel: "arrow-left", delete: "exclamation-triangle", add: "plus",
                                new_user: "user", login: "sign-in", help: 'question-circle', logout: 'sign-out',
                                people: "user", blog: "newspaper-o", add_user: 'user-plus', leave: 'sign-out',
                                email: "envelope-o", alert: "exclamation-triangle", network: "code-fork", article: "file-text",
                                down_arrow: "chevron-down", fullscreen: "arrows-alt", spread: 'share-alt', file: "file-text-o",
                                ellipsis: "ellipsis-h", lightbulb: 'lightbulb-o', clock: 'clock-o', ok: 'check' }
    type = noosfero_to_fontawesome[type.to_sym] if noosfero_to_fontawesome.key? type.to_sym
    fa = content_tag(:i, nil, class: "fa fa-#{type}", 'aria-hidden' => true)
    (fa + label).html_safe
  end

  def button_bar(options = {}, &block)
    options[:class] ||= ''
    options[:class] << ' button-bar'

    content_tag :div, options do
      [
        capture(&block).to_s
      ].safe_join
    end
  end

  def button(type, label, url, html_options = {})
    klass = 'with-text'
    if html_options.has_key?(:class)
      klass << ' ' << html_options[:class]
    end
    button_without_text type, font_awesome(type, label), url, html_options.merge(class: klass, title: label)
  end

  def button_without_text(type, label, url, html_options = {})
    klass = "button icon-#{type}"
    if html_options.has_key?(:class)
      klass << ' ' << html_options[:class]
    end
    title = html_options[:title] || label
    if html_options[:disabled]
      content_tag('a', label, html_options.merge(class: klass, title: title))
    else
      link_to(label, url, html_options.merge(class: klass, title: title))
    end
  end

  def button_to_function(type, label, js_code, html_options = {}, &block)
    html_options[:class] = "button with-text" unless html_options[:class]
    html_options[:class] << " icon-#{type}"
    link_to_function(font_awesome(type, label), j(js_code), html_options, &block)
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
