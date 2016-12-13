module LayoutHelper

  def body_classes
    # Identify the current controller and action for the CSS:
    [
      (logged_in? ? 'logged-in' : nil),
      "controller-#{controller.controller_name}",
      "action-#{controller.controller_name}-#{controller.action_name}",
      "template-#{@layout_template || if profile.blank? then 'default' else profile.layout_template end}",
      !profile.nil? && profile.is_on_homepage?(request.path,@page) ? 'profile-homepage' : nil,
      profile.present? ? profile.kinds_style_classes : nil,
    ].compact.join(' ')
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
    plugins_javascripts = @plugins.flat_map{ |plugin| Array.wrap(plugin.js_files).map{ |js| plugin.class.public_path(js, true) } }.flatten

    output = ''
    output += render 'layouts/javascript'
    unless plugins_javascripts.empty?
      output += javascript_include_tag *plugins_javascripts
    end
    output += theme_javascript_ng.to_s
    output += javascript_tag 'render_all_jquery_ui_widgets()'

    output += templete_javascript_ng.to_s

    # This output should be safe!
    output.html_safe
  end

  def noosfero_stylesheets
    plugins_stylesheets = @plugins.select(&:stylesheet?).map { |plugin|
      plugin.class.public_path('style.css', true)
    }
    global_css_pub = "/designs/themes/#{environment.theme}/global.css"
    global_css_at_fs = Rails.root.join 'public' + global_css_pub

    output = []
    output << stylesheet_link_tag('application')
    output << stylesheet_link_tag(template_stylesheet_path)
    output << stylesheet_link_tag(*icon_theme_stylesheet_path)
    output << stylesheet_link_tag(jquery_ui_theme_stylesheet_path)
    unless plugins_stylesheets.empty?
      # FIXME: caching does not work with asset pipeline
      #cacheid = "cache/plugins-#{Digest::MD5.hexdigest plugins_stylesheets.to_s}"
      output << stylesheet_link_tag(*plugins_stylesheets)
    end
    if File.exists? global_css_at_fs
      output << stylesheet_link_tag(global_css_pub)
    end
    output << stylesheet_link_tag(theme_stylesheet_path)

    # This output should be safe!
    output.join("\n").html_safe
  end

  def noosfero_layout_features
    render :file => 'shared/noosfero_layout_features'
  end

  def template_stylesheet_path
    File.join template_path, "/stylesheets/style.css"
  end


  def icon_theme_stylesheet_path
    theme_icon_themes = theme_option(:icon_theme) || []
    theme_icon_themes.map{ |it| "designs/icons/#{it}/style.css" }
  end

  def jquery_ui_theme_stylesheet_path
    "https://code.jquery.com/ui/1.10.4/themes/#{jquery_theme}/jquery-ui.css"
  end

  def theme_stylesheet_path
    "#{theme_path}/style.css".gsub(%r{^/}, '')
  end

  def layout_template
    if profile then profile.layout_template else environment.layout_template end
  end

  def addthis_javascript
    NOOSFERO_CONF['addthis_enabled'] ? '<script src="https://s7.addthis.com/js/152/addthis_widget.js"></script>' : ''
  end

end

