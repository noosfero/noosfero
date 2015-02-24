module LayoutHelper

  def body_classes
    # Identify the current controller and action for the CSS:
    (logged_in? ? " logged-in" : "") +
    " controller-#{controller.controller_name}" +
    " action-#{controller.controller_name}-#{controller.action_name}" +
    " template-#{@layout_template || if profile.blank? then 'default' else profile.layout_template end}" +
    (!profile.nil? && profile.is_on_homepage?(request.path,@page) ? " profile-homepage" : "")
  end

  def html_tag_classes
    [
      body_classes, (
        profile.blank? ? nil : [
          'profile-type-is-' + profile.class.name.downcase,
          'profile-name-is-' + profile.identifier,
        ]
      ), 'theme-' + current_theme,
      @plugins.dispatch(:html_tag_classes).map do |content|
        if content.respond_to?(:call)
          instance_exec(&content)
        else
          content.html_safe
        end
      end
    ].flatten.compact.join(' ')
  end

  def noosfero_javascript
    plugins_javascripts = @plugins.map { |plugin| [plugin.js_files].flatten.map { |js| plugin.class.public_path(js) } }.flatten

    output = ''
    output += render :file =>  'layouts/_javascript'
    output += javascript_tag 'render_all_jquery_ui_widgets()'
    unless plugins_javascripts.empty?
      output += javascript_include_tag plugins_javascripts, :cache => "cache/plugins-#{Digest::MD5.hexdigest plugins_javascripts.to_s}"
    end
    output += theme_javascript_ng.to_s

    output
  end

  def noosfero_stylesheets
    standard_stylesheets = [
      'application',
      'search',
      'colorbox',
      'selectordie',
      'inputosaurus',
      'chat',
      pngfix_stylesheet_path,
    ] + tokeninput_stylesheets
    plugins_stylesheets = @plugins.select(&:stylesheet?).map { |plugin| plugin.class.public_path('style.css') }

    output = ''
    output += stylesheet_link_tag standard_stylesheets, :cache => 'cache/application'
    output += stylesheet_link_tag template_stylesheet_path
    output += stylesheet_link_tag icon_theme_stylesheet_path
    output += stylesheet_link_tag jquery_ui_theme_stylesheet_path
    unless plugins_stylesheets.empty?
      output += stylesheet_link_tag plugins_stylesheets, :cache => "cache/plugins-#{Digest::MD5.hexdigest plugins_stylesheets.to_s}"
    end
    output += stylesheet_link_tag theme_stylesheet_path
    output
  end

  def pngfix_stylesheet_path
    'iepngfix/iepngfix.css'
  end

  def tokeninput_stylesheets
    ['token-input', 'token-input-facebook', 'token-input-mac', 'token-input-facet']
  end

  def noosfero_layout_features
    render :file => 'shared/noosfero_layout_features'
  end

  def template_stylesheet_path
    if profile.nil?
      "/designs/templates/#{environment.layout_template}/stylesheets/style.css"
    else
      "/designs/templates/#{profile.layout_template}/stylesheets/style.css"
    end
  end

  def icon_theme_stylesheet_path
    icon_themes = []
    theme_icon_themes = theme_option(:icon_theme) || []
    for icon_theme in theme_icon_themes do
      theme_path = "/designs/icons/#{icon_theme}/style.css"
      if File.exists?(Rails.root.join('public', theme_path))
        icon_themes << theme_path
      end
    end
    icon_themes
  end

  def jquery_ui_theme_stylesheet_path
    "https://code.jquery.com/ui/1.10.4/themes/#{jquery_theme}/jquery-ui.css"
  end

  def theme_stylesheet_path
    theme_path + '/style.css'
  end

  def layout_template
    if profile then profile.layout_template else environment.layout_template end
  end

  def addthis_javascript
    if NOOSFERO_CONF['addthis_enabled']
      '<script src="https://s7.addthis.com/js/152/addthis_widget.js"></script>'
    end
  end

end

