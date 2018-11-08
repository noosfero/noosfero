module ButtonsHelper

  NOOSFERO_TO_FONTAWESOME = {
    add:               'plus',
    add_admin:         'shield-alt',
    add_user:          'user-plus',
    admin_user:        'user-shield',
    admin:             'shield-alt',
    angle_right:       'angle-right',
    control_panel:     'cog',
    alert:             'exclamation-triangle',
    appearance:        'paint-brush',
    application:       'file',
    article:           'file-alt',
    audio:             'volume-up',
    back:              'arrow-left',
    ban:               'ban',
    blocks:            'th',
    blog:              'newspaper',
    bug:               'bug',
    cancel:            'times',
    caret_down:        'caret-down',
    clear:             'eraser',
    clock:             'clock',
    clone:             'clone',
    comments:          'comments',
    cut:               'cut',
    delete:            'exclamation-triangle',
    down:              'arrow-circle-down',
    down_arrow:        'chevron-down',
    download:          'download',
    ellipsis:          'ellipsis-h',
    email:             'envelope',
    enterprise:        'suitcase',
    event:             'calendar-alt',
    file:              'file-alt',
    file_code:         'file-code',
    folder:            'folder',
    forward:           'forward',
    fullscreen:        'expand-arrows-alt',
    fullscreen_out:    'compress',
    goble:             'goble',
    header_footer:     'object-group',
    heart:             'heart',
    help:              'question-circle',
    home:              'home',
    image:             'image',
    info:              'info',
    language:          'language',
    leave:             'sign-out-alt',
    left:              'arrow-circle-left',
    lightbulb:         'lightbulb',
    lock:              'lock',
    login:             'sign-in-alt',
    logout:            'sign-out-alt',
    menu:              'align-justify',
    minus:             'minus',
    more_right:        'angle-double-right',
    network:           'code-branch',
    new:               'plus',
    next:              'arrow-right',
    none:              '',
    ok:                'check',
    pdf:               'file-pdf',
    people:            'user',
    reload:            'redo',
    remove:            'times',
    remove_user:       'user-times',
    reply:             'reply',
    right:             'arrow-circle-right',
    rss:               'rss',
    save:              'save',
    save_and_continue: 'cloud-upload-alt',
    search:            'search',
    see_more:          'plus-circle',
    slideshow:         'tv',
    spread:            'share-alt',
    star:              'star',
    tag:               'tag',
    task:              'tasks',
    text:              'file-alt',
    trash:             'trash-alt',
    undo:              'undo',
    upload:            'upload',
    up:                'arrow-circle-up',
    welcome_page:      'home',
    zoom:              'search-plus',
    zoom_out:          'search-minus',
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
    classes = "button icon-#{type}"
    html_options = merge_class(classes, html_options)
    html_options[:title] ||= label
    link_to(font_awesome(type, label), url, html_options.merge(class: classes))
  end

  def button(type, label, url, html_options = {})
    generic_button(type, label, url, merge_class('with-text', html_options))
  end

  def button_without_text(type, label, url, html_options = {})
    html_options[:title] = label
    generic_button(type, '', url, merge_class('without-text', html_options))
  end

  def button_to_function(type, label, js_code, html_options = {}, &block)
    html_options[:class] = "button with-text" unless html_options[:class]
    html_options[:class] << " icon-#{type}"
    link_to_function(font_awesome(type, label), j(js_code), html_options, &block)
  end

  def button_to_function_without_text(type, label, js_code, html_options = {}, &block)
    html_options[:title] = label
    html_options = merge_class("button without-text icon-#{type}")
    link_to_function(font_awesome(type), js_code, html_options, &block)
  end

  def button_to_remote(type, label, options, html_options = {})
    html_options[:class] = "button with-text" unless html_options[:class]
    html_options[:class] << " icon-#{type}"
    link_to_remote(label, options, html_options)
  end

  def button_to_remote_without_text(type, label, options, html_options = {})
    html_options[:class] = "" unless html_options[:class]
    html_options[:class] << " button without-text icon-#{type}"
    link_to_remote(font_awesome(type), options, html_options.merge(:title => label))
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

  private

  def merge_class klass, html_options = {}
    classes = klass
    classes << ' ' << html_options[:class] if html_options.has_key?(:class)
    html_options.merge(class: classes)
  end
end
