module ButtonsHelper

  NOOSFERO_TO_FONTAWESOME = {
    add:               'plus',
    add_user:          'user-plus',
    alert:             'exclamation-triangle',
    appearance:        'paint-brush',
    application:       'file',
    article:           'file-alt',
    audio:             'volume-up',
    back:              'arrow-left',
    ban:               'ban',
    blocks:            'th',
    blog:              'newspaper',
    cancel:            'arrow-left',
    clear:             'eraser',
    clock:             'clock',
    delete:            'exclamation-triangle',
    down_arrow:        'chevron-down',
    ellipsis:          'ellipsis-h',
    email:             'envelope',
    event:             'calendar-alt',
    file:              'file-alt',
    fullscreen:        'expand-arrows-alt',
    header_footer:     'object-group',
    help:              'question-circle',
    leave:             'sign-out-alt',
    lightbulb:         'lightbulb',
    login:             'sign-in-alt',
    logout:            'sign-out-alt',
    network:           'code-branch',
    new:               'plus',
    new_user:          'user',
    next:              'arrow-right',
    ok:                'check',
    pdf:               'file-pdf',
    people:            'user',
    remove:            'times',
    save_and_continue: 'cloud-upload-alt',
    spread:            'share-alt',
    text:              'file-alt',
    menu:              'align-justify',
    trash:             'trash-alt',
    welcome_page:      'home'
  }

  def font_awesome type, label = ""
    type = NOOSFERO_TO_FONTAWESOME[type.to_sym] if NOOSFERO_TO_FONTAWESOME.key? type.to_sym
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

  def generic_button(type, label, url, html_options = {})
    classes = 'button'
    classes << ' ' << html_options[:class] if html_options.has_key?(:class)
    html_options[:title] ||= label
    link_to(url, html_options.merge(class: classes)) do
      font_awesome(type, label)
    end
  end

  def button(type, label, url, html_options = {})
    classes = 'with-text'
    classes << ' ' << html_options[:class] if html_options.has_key?(:class)
    generic_button(type, label, url, html_options.merge(class: classes))
  end

  def button_without_text(type, label, url, html_options = {})
    classes = 'without-text'
    classes << ' ' << html_options[:class] if html_options.has_key?(:class)
    html_options[:title] = label
    generic_button(type, '', url, html_options.merge(class: classes))
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

  def generate_button(type, label, url, html_options = {})
    klass = "button icon-#{type}"
    if html_options.has_key?(:class)
      klass << ' ' << html_options[:class]
    end
    title = html_options[:title] || label
    label = font_awesome(type, label)
    if html_options[:disabled]
      content_tag('a', label, html_options.merge(class: klass, title: title))
    else
      link_to(label, url, html_options.merge(class: klass, title: title))
    end
  end
end
