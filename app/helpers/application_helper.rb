# encoding: UTF-8

require 'redcloth'

# Methods added to this helper will be available to all templates in the
# application.
module ApplicationHelper

  include PermissionNameHelper

  include ModalHelper

  include BoxesHelper

  include FormsHelper

  include AssetsHelper

  include BlockHelper

  include DatesHelper

  include FolderHelper

  include ProfileEditorHelper

  include DisplayHelper

  include AccountHelper

  include CommentHelper

  include BlogHelper

  include ContentViewerHelper

  include LayoutHelper

  include Noosfero::Gravatar

  include TokenHelper

  include CatalogHelper

  include PluginsHelper

  def locale
    (@page && !@page.language.blank?) ? @page.language : FastGettext.locale
  end

  # Displays context help. You can pass the content of the help message as the
  # first parameter or using template code inside a block passed to this
  # method. *Note*: the block is ignored if <tt>content</tt> is not
  # <tt>nil</tt>
  #
  # The method returns the text generated, so you can also use it inside a
  #  <%= ... %>
  #
  # Follow some examples ...
  #
  # Passing the text as argument:
  #
  #  <% help 'This your help message' %>
  #
  # Using a block:
  #
  #  <% help do %>
  #    This is the help message to be displayed. It can contain any HTML you
  #    want: <strong>bold</strong>, <em>italic</em>. It can also contain calls
  #    to any Rails helper, like <%= link_to 'home', :controller => 'home' %>.
  #  <% end %>
  #
  # You can also pass an optional argument to force the use of textile in your
  # help message:
  #
  #  <% help nil, :textile do %>
  #    You can also use *textile*!
  #  <% end %>
  #
  # or, using the return of the method:
  #
  #  <%= help 'this is your help message' %>
  #
  # Formally, the <tt>type</tt> argument can be <tt>:html</tt> (i.e. no
  # conversion of the input) or <tt>:textile</tt> (converts the message, in
  # textile, into HTML). It defaults to <tt>:html</tt>.
  #
  # TODO: implement correcly the 'Help' button click
  def help(content = nil, link_name = nil, options = {}, &block)

    link_name ||= _('Help')

    @help_message_id ||= 1
    help_id = "help_message_#{@help_message_id}"

    if content.nil?
      return '' if block.nil?
      content = capture(&block)
    end

    if options[:type] == :textile
      content = RedCloth.new(content).to_html
    end

    options[:class] = '' if ! options[:class]
    options[:class] += ' button icon-help' # with-text

    # TODO: implement this button, and add style='display: none' to the help
    # message DIV
    button = link_to_function(content_tag('span', link_name), "Element.show('#{help_id}')", options )
    close_button = content_tag("div", link_to_function(_("Close"), "Element.hide('#{help_id}')", :class => 'close_help_button'))

    text = content_tag('div', button + content_tag('div', content_tag('div', content) + close_button, :class => 'help_message', :id => help_id, :style => 'display: none;'), :class => 'help_box')

    unless block.nil?
      concat(text)
    end

    text
  end

  # alias for <tt>help(content, :textile)</tt>. You can pass a block in the
  # same way you would do if you called <tt>help</tt> directly.
  def help_textile(content = nil, link_name = nil, options = {}, &block)
    options[:type] = :textile
    help(content, link_name, options, &block)
  end

  # TODO: do something more useful here
  # TODO: test this helper
  # TODO: add an icon?
  # TODO: the command rake test:rcov didn't works because of this method. See what it's the problem
  def environment_identification
    content_tag('div', @environment.name, :id => 'environment_identification')
  end

  def link_to_cms(text, profile = nil, options = {})
    profile ||= current_user.login
    link_to text, myprofile_path(:controller => 'cms', :profile => profile), options
  end

  def link_to_profile(text, profile = nil, options = {})
    profile ||= current_user.login
    link_to text, profile_path(:profile => profile) , options
  end

  def link_to_homepage(text, profile = nil, options = {})
    p = if profile
          Profile[profile]
        else
          user
        end

    link_to text, p.url, options
  end

  def link_if_permitted(link, permission = nil, target = nil)
    if permission.nil? || current_user.person.has_permission?(permission, target)
      link
    else
      nil
    end
  end

  def footer
    # FIXME: add some information from the environment
    [
      content_tag('div', _('This is %s, version %s') % [ link_to(Noosfero::PROJECT, 'http://www.noosfero.com.br/'), Noosfero::VERSION]),
    ].join("\n")
  end

  # returns the current profile beign viewed.
  #
  # Make sure that you use this helper method only in contexts where there
  # should be a current profile (i.e. while viewing some profile's pages, or the
  # profile info, etc), because if there is no profile an exception is thrown.
  def profile
    controller.send(:profile)
  end

  def category_color
    if @category.nil?
      ""
    else
      @category.top_ancestor.display_color
    end
  end

  def text_editor(object, method, filter_type_method = nil, options = {})
    text_area(object, method, { :rows => 10, :cols => 64 }.merge(options))
  end

  def hide(id)
    "Element.hide(#{id.inspect});"
  end

  def show(id)
    "Element.show(#{id.inspect});"
  end

  def toggle_panel(hide_label, show_label, id)
    hide_button_id = id + "-hide"
    show_button_id = id + "-show"

    result = ""
    result << button_to_function('open', show_label, show(id) + show(hide_button_id) + hide(show_button_id), :id => show_button_id, :class => 'show-button with-text', :style => 'display: none;' )

    result < " "
    result << button_to_function('close', hide_label, hide(id) + hide(hide_button_id) + show(show_button_id), :id => hide_button_id, :class => 'hide-button with-text')

    result
  end

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

  def icon(icon_name, html_options = {})
    the_class = "button #{icon_name}"
    if html_options.has_key?(:class)
      the_class << ' ' << html_options[:class]
    end
    content_tag('div', '', html_options.merge(:class => the_class))
  end

  def icon_button(type, text, url, html_options = {})
    the_class = "button icon-button icon-#{type}"
    if html_options.has_key?(:class)
      the_class << ' ' << html_options[:class]
    end

    link_to(content_tag('span', text), url, html_options.merge(:class => the_class, :title => text))
  end

  def button_bar(options = {}, &block)
    options[:class].nil? ?
      options[:class]='button-bar' :
      options[:class]+=' button-bar'
    concat(content_tag('div', capture(&block).to_s + tag('br', :style => 'clear: left;'), options))
  end


  def partial_for_class_in_view_path(klass, view_path, prefix = nil, suffix = nil)
    return nil if klass.nil?
    name = [prefix, klass.name.underscore, suffix].compact.map(&:to_s).join('_')

    search_name = String.new(name)
    if search_name.include?("/")
      search_name.gsub!(/(\/)([^\/]*)$/,'\1_\2')
      name = File.join(params[:controller], name) if defined?(params) && params[:controller]
    else
      search_name = "_" + search_name
    end

    path = defined?(params) && params[:controller] ? File.join(view_path, params[:controller], search_name + '.html.erb') : File.join(view_path, search_name + '.html.erb')
    return name if File.exists?(File.join(path))

    partial_for_class_in_view_path(klass.superclass, view_path, prefix, suffix)
  end

  def partial_for_class(klass, prefix=nil, suffix=nil)
    raise ArgumentError, 'No partial for object. Is there a partial for any class in the inheritance hierarchy?' if klass.nil?
    name = klass.name.underscore
    controller.view_paths.each do |view_path|
      partial = partial_for_class_in_view_path(klass, view_path, prefix, suffix)
      return partial if partial
    end

    raise ArgumentError, 'No partial for object. Is there a partial for any class in the inheritance hierarchy?'
  end

  def render_profile_actions klass
    name = klass.to_s.underscore
    begin
      render "blocks/profile_info_actions/#{name}"
    rescue ActionView::MissingTemplate
      render_profile_actions klass.superclass
    end
  end

  def user
    controller.send(:user)
  end

  # DEPRECATED. Do not use this.
  def stylesheet_import(*sources)
    options = sources.last.is_a?(Hash) ? sources.pop : { }
    themed_source = options.delete(:themed_source)
    content_tag(
      'style',
      "\n" +
      sources.flatten.map do |source|
        filename = filename_for_stylesheet(source.to_s, themed_source)
        if File.exists?(Rails.root.join('public', filename[1..-1]))
          "@import url(#{filename});\n"
        else
          "/* Not included: url(#{filename}) */\n"
        end
      end.join(),
      { "type" => "text/css" }.merge(options)
    )
  end

  # DEPRECATED. Do not use this.
  def filename_for_stylesheet(name, in_theme)
    result = ''
    if in_theme
      result << theme_path
    end
    name += '.css'  if ( name[-4..-1] != '.css' )
    if ( name[0..0] == '/' )
      result << name
    else
      result << '/stylesheets/' << name
    end
  end

  def theme_path
    if session[:theme]
      '/user_themes/' + current_theme
    else
      '/designs/themes/' + current_theme
    end
  end

  def current_theme
    @current_theme ||=
      begin
        if session[:theme]
          session[:theme]
        else
          # utility for developers: set the theme to 'random' in development mode and
          # you will get a different theme every request. This is interesting for
          # testing
          if Rails.env.development? && environment.theme == 'random'
            @random_theme ||= Dir.glob('public/designs/themes/*').map { |f| File.basename(f) }.rand
            @random_theme
          elsif Rails.env.development? && respond_to?(:params) && params[:theme] && File.exists?(Rails.root.join('public/designs/themes', params[:theme]))
            params[:theme]
          else
            if profile && !profile.theme.nil?
              profile.theme
            elsif environment
              environment.theme
            else
              if logger
                logger.warn("No environment found. This is weird.")
                logger.warn("Request environment: %s" % request.env.inspect)
                logger.warn("Request parameters: %s" % params.inspect)
              end

              # could not determine the theme, so return the default one
              'default'
            end
          end
        end
      end
  end

  def theme_view_file(template, theme=nil)
    # Since we cannot control what people are doing in external themes, we
    # will keep looking for the deprecated .rhtml extension here.
    addr = theme ? "designs/themes/#{theme}" : theme_path[1..-1]
    file = Rails.root.join('public', addr, template + '.html.erb')
    return file if File.exists?(file)
    nil
  end

  def theme_include(template, options = {})
    from_theme_include(nil, template, options)
  end

  def env_theme_include(template, options = {})
    from_theme_include(environment.theme, template, options)
  end

  def from_theme_include(theme, template, options = {})
    file = theme_view_file(template, theme)
    if file
      render options.merge(file: file, use_full_path: false)
    else
      nil
    end
  end

  def theme_favicon
    return '/designs/themes/' + current_theme + '/favicon.ico' if profile.nil? || profile.theme.nil?
    if File.exists?(Rails.root.join('public', theme_path, 'favicon.ico'))
      '/designs/themes/' + profile.theme + '/favicon.ico'
    else
      favicon = profile.articles.find_by_path('favicon.ico')
      if favicon
        favicon.public_filename
      else
        '/designs/themes/' + environment.theme + '/favicon.ico'
      end
    end
  end

  def theme_site_title
    @theme_site_title ||= theme_include 'site_title'
  end

  def theme_header
    @theme_header ||= theme_include 'header'
  end

  def theme_footer
    @theme_footer ||= theme_include 'footer'
  end

  def theme_extra_navigation
    @theme_extra_navigation ||= theme_include 'navigation'
  end

  def global_header
    @global_header ||= env_theme_include 'global_header'
  end

  def global_footer
    @global_footer ||= env_theme_include 'global_footer'
  end

  def is_testing_theme
    !controller.session[:theme].nil?
  end

  def theme_owner
    Theme.find(current_theme).owner.identifier
  end

  # generates a image tag for the profile.
  #
  # If the profile has no image set yet, then a default image is used.
  def profile_image(profile, size=:portrait, opt={})
    return '' if profile.nil?
    opt[:alt]   ||= profile.name()
    opt[:title] ||= ''
    opt[:class] ||= ''
    opt[:class] += ( profile.class == Person ? ' photo' : ' logo' )
    image_tag(profile_icon(profile, size), opt )
  end

  def profile_icon( profile, size=:portrait, return_mimetype=false )
    filename, mimetype = '', 'image/png'
    if profile.image
      filename = profile.image.public_filename( size )
      mimetype = profile.image.content_type
    else
      icon =
        if profile.organization?
          if profile.kind_of?(Community)
            '/images/icons-app/community-'+ size.to_s() +'.png'
          else
            '/images/icons-app/enterprise-'+ size.to_s() +'.png'
          end
        else
          pixels = Image.attachment_options[:thumbnails][size].split('x').first
          gravatar_profile_image_url(
            profile.email,
            :size => pixels,
            :d => gravatar_default
          )
        end
      filename = default_or_themed_icon(icon)
    end
    return_mimetype ? [filename, mimetype] : filename
  end

  def default_or_themed_icon(icon)
    if File.exists?(Rails.root.join('public', theme_path, icon))
      theme_path + icon
    else
      icon
    end
  end

  def profile_sex_icon( profile )
    return '' unless profile.is_a?(Person)
    return '' unless !environment.enabled?('disable_gender_icon')
    sex = ( profile.sex ? profile.sex.to_s() : 'undef' )
    title = ( sex == 'undef' ? _('non registered gender') : ( sex == 'male' ? _('Male') : _('Female') ) )
    sex = content_tag 'span',
                      content_tag( 'span', sex ),
                      :class => 'sex-'+sex,
                      :title => title
    sex
  end

  def profile_cat_icons( profile )
    if profile.class == Enterprise
      icons = profile.product_categories.unique_by_level(2).limit(3).map do |c|
        filtered_category = c.filtered_category.blank? ? c.path.split('/').last : c.filtered_category
        category_title = filtered_category.split(/[-_\s,.;'"]+/).map(&:capitalize).join(' ')
        category_name = category_title.gsub(' ', '_' )
        category_icon = "/images/icons-cat/#{category_name}.png"
        if ! File.exists?(Rails.root.join('public', category_icon))
          category_icon = '/images/icons-cat/undefined.png'
        end
        content_tag('span',
          content_tag( 'span', category_title ),
          :title => category_title,
          :class => 'product-cat-icon cat_icon_' + category_name,
          :style => "background-image:url(#{category_icon})"
        )
      end.join("\n").html_safe
      content_tag('div',
        content_tag( 'span', _('Principal Product Categories'), :class => 'header' ) +"\n"+ icons,
        :class => 'product-category-icons'
      )
    else
      ''
    end
  end

  def links_for_balloon(profile)
    if environment.enabled?(:show_balloon_with_profile_links_when_clicked)
      if profile.kind_of?(Person)
        [
          {_('Wall') => {:href => url_for(profile.public_profile_url)}},
          {_('Friends') => {:href => url_for(:controller => :profile, :action => :friends, :profile => profile.identifier)}},
          {_('Communities') => {:href => url_for(:controller => :profile, :action => :communities, :profile => profile.identifier)}},
          {_('Send an e-mail') => {:href => url_for(:profile => profile.identifier, :controller => 'contact', :action => 'new'), :class => 'send-an-email', :style => 'display: none'}},
          {_('Add') => {:href => url_for(profile.add_url), :class => 'add-friend', :style => 'display: none'}}
        ]
      elsif profile.kind_of?(Community)
        [
          {_('Wall') => {:href => url_for(profile.public_profile_url)}},
          {_('Members') => {:href => url_for(:controller => :profile, :action => :members, :profile => profile.identifier)}},
          {_('Agenda') => {:href => url_for(:controller => :profile, :action => :events, :profile => profile.identifier)}},
          {_('Join') => {:href => url_for(profile.join_url), :class => 'join-community', :style => 'display: none'}},
          {_('Leave community') => {:href => url_for(profile.leave_url), :class => 'leave-community', :style => 'display:  none'}},
          {_('Send an e-mail') => {:href => url_for(:profile => profile.identifier, :controller => 'contact', :action => 'new'), :class => 'send-an-email', :style => 'display: none'}}
        ]
      elsif profile.kind_of?(Enterprise)
        [
          {_('Products') => {:href => catalog_path(profile.identifier)}},
          {_('Members') => {:href => url_for(:controller => :profile, :action => :members, :profile => profile.identifier)}},
          {_('Agenda') => {:href => url_for(:controller => :profile, :action => :events, :profile => profile.identifier)}},
          {_('Send an e-mail') => {:href => url_for(:profile => profile.identifier, :controller => 'contact', :action => 'new'), :class => 'send-an-email', :style => 'display: none'}},
        ]
      else
        []
      end
    end
  end

  # displays a link to the profile homepage with its image (as generated by
  # #profile_image) and its name below it.
  def profile_image_link( profile, size=:portrait, tag='li', extra_info = nil )
    if content = @plugins.dispatch_first(:profile_image_link, profile, size, tag, extra_info)
      return instance_exec(&content)
    end
    name = profile.short_name
    if profile.person?
      url = url_for(profile.check_friendship_url)
      trigger_class = 'person-trigger'
    else
      city = ''
      url = url_for(profile.check_membership_url)
      if profile.community?
        trigger_class = 'community-trigger'
      elsif profile.enterprise?
        trigger_class = 'enterprise-trigger'
      end
    end
    extra_info = extra_info.nil? ? '' : content_tag( 'span', extra_info, :class => 'extra_info' )
    links = links_for_balloon(profile)
    content_tag('div', content_tag(tag,
                                   (environment.enabled?(:show_balloon_with_profile_links_when_clicked) ? popover_menu(_('Profile links'),profile.short_name,links,{:class => trigger_class, :url => url}) : "") +
    link_to(
      content_tag( 'span', profile_image( profile, size ), :class => 'profile-image' ) +
      content_tag( 'span', h(name), :class => ( profile.class == Person ? 'fn' : 'org' ) ) +
      extra_info + profile_sex_icon( profile ) + profile_cat_icons( profile ),
      profile.url,
      :class => 'profile_link url',
      :help => _('Click on this icon to go to the <b>%s</b>\'s home page') % profile.name,
      :title => profile.name ),
      :class => 'vcard'), :class => 'common-profile-list-block')
  end

  def popover_menu(title,menu_title,links,html_options={})
    html_options[:class] = "" unless html_options[:class]
    html_options[:class] << " menu-submenu-trigger"
    html_options[:onclick] = "toggleSubmenu(this, '#{menu_title}', #{CGI::escapeHTML(links.to_json)}); return false"

    link_to(content_tag(:span, title), '#', html_options)
  end

  def gravatar_default
    (respond_to?(:theme_option) && theme_option.present? && theme_option['gravatar']) || NOOSFERO_CONF['gravatar'] || 'mm'
  end

  attr_reader :environment

  def select_categories(object_name, title=nil, title_size=4)
    return nil if environment.enabled?(:disable_categories)
    if title.nil?
      title = _('Categories')
    end

    @object = instance_variable_get("@#{object_name}")
    @categories = environment.top_level_categories

    @current_categories = environment.top_level_categories.select{|i| !i.children.empty?}
    render :partial => 'shared/select_categories_top', :locals => {:object_name => object_name, :title => title, :title_size => title_size, :multiple => true, :categories_selected => @object.categories }, :layout => false
  end

  def theme_option(opt = nil)
    conf = Rails.root.to_s() +
           '/public' + theme_path +
           '/theme.yml'
    if File.exists?(conf)
      opt ? YAML.load_file(conf)[opt.to_s()] : YAML.load_file(conf)
    else
      nil
    end
  end

  def theme_opt_menu_search
    opt = theme_option( :menu_search )
    if    opt == 'none'
      ""
    elsif opt == 'simple_search'
      s = _('Search...')
      "<form action=\"#{url_for(:controller => 'search', :action => 'index')}\" id=\"simple-search\" class=\"focus-out\""+
      ' help="'+_('This is a search box. Click, write your query, and press enter to find')+'"'+
      ' title="'+_('Click, write and press enter to find')+'">'+
      '<input name="query" value="'+s+'"'+
      ' onfocus="if(this.value==\''+s+'\'){this.value=\'\'} this.form.className=\'focus-in\'"'+
      ' onblur="if(/^\s*$/.test(this.value)){this.value=\''+s+'\'} this.form.className=\'focus-out\'">'+
      '</form>'
    else
      modal_link_to '<span class="icon-menu-search"></span>'+ _('Search'), {
                       :controller => 'search',
                       :action => 'popup',
                       :category_path => (@category ? @category.explode_path : nil)},
                       :id => 'open_search'
    end
  end

  def theme_javascript
    option = theme_option(:js)
    return if option.nil?
    html = []
    option.each do |file|
      file = theme_path +
             '/javascript/'+ file +'.js'
      if File.exists? Rails.root.to_s() +'/public'+ file
        html << javascript_src_tag( file, {} )
      else
        html << '<!-- Not included: '+ file +' -->'
      end
    end
    html.join "\n"
  end

  def theme_javascript_src
    script = File.join theme_path, 'theme.js'
    script if File.exists? File.join(Rails.root, 'public', script)
  end

  def theme_javascript_ng
    script = theme_javascript_src
    javascript_include_tag script if script
  end

  def template_path
    if profile.nil?
      "/designs/templates/#{environment.layout_template}"
    else
      "/designs/templates/#{profile.layout_template}"
    end
  end

  def template_javascript_src
    script = File.join template_path, '/javascripts/template.js'
    script if File.exists? File.join(Rails.root, 'public', script)
  end

  def templete_javascript_ng
    script = template_javascript_src
    javascript_include_tag script if script
  end

  def file_field_or_thumbnail(label, image, i, removable = true)
    display_form_field label, (
      render :partial => (image && image.valid? ? 'shared/show_thumbnail' : 'shared/change_image'),
      :locals => { :i => i, :image => image, :removable => removable }
      )
  end

  def rolename_for(profile, resource)
    roles = profile.role_assignments.
      where(:resource_id => resource.id).
      sort_by{ |role_assignment| role_assignment.role_id }.
      map(&:role)
    names = []
    roles.each do |role|
      names << content_tag('span', role.name, :style => "color: #{role_color(role, resource.environment.id)}")
    end
    names.join(', ')
  end

  def role_color(role, env_id)
    case role
      when Profile::Roles.admin(env_id)
        'blue'
      when Profile::Roles.member(env_id)
        'green'
      when Profile::Roles.moderator(env_id)
        'gray'
      else
        'black'
    end
  end

  # Should be on the forms_helper file but when its there the translation of labels doesn't work
  class NoosferoFormBuilder < ActionView::Helpers::FormBuilder
    extend ActionView::Helpers::TagHelper

    def self.output_field(text, field_html, field_id = nil, options = {})
      # try to guess an id if none given
      if field_id.nil?
        field_html =~ /id=['"]([^'"]*)['"]/
        field_id = $1
      end
      field_html =~ /type=['"]([^'"]*)['"]/
      field_html =~ /<(\w*)/ unless $1
      field_type = $1
      field_class = 'formfield type-' + field_type if field_type

      label_html = content_tag('label', gettext(text), :class => 'formlabel', :for => field_id)
      control_html = content_tag('div', field_html, :class => field_class )

      content_tag('div', label_html + control_html, :class => 'formfieldline' )
    end

    (field_helpers - %w(hidden_field)).each do |selector|
      src = <<-END_SRC
        def #{selector}(field, *args, &proc)
          begin
            object ||= @template.instance_variable_get("@"+object_name.to_s)
          rescue
          end
          text = object.class.respond_to?(:human_attribute_name) && object.class.human_attribute_name(field.to_s) || field.to_s.humanize
          NoosferoFormBuilder::output_field(text, super)
        end
      END_SRC
      class_eval src, __FILE__, __LINE__
    end

    # Create a formatable radio collection
    # Tha values parameter is a array of [value, label] arrays like this:
    # [ ['en',_('English')], ['pt',_('Portuguese')], ['es',_('Spanish')] ]
    # The option :size will set how many radios will be showed in each line
    # Example: use :size => 3 as option if you want 3 radios by line
    def radio_group( object_name, method, values, options = {} )
      line_size = options[:size] || 0
      line_item = 0
      html = "\n"
      values.each { |val, h_val|
        id = object_name.to_s() +'_'+ method.to_s() +'_'+ val.to_s()
        # Não está apresentando o sexo selecionado ao revisitar
        # http://localhost:3000/myprofile/manuel/profile_editor/edit  :-(
        html += self.class.content_tag( 'span',
            @template.radio_button( object_name, method, val,
                                    :id => id, :object => @object ) +
            self.class.content_tag( 'label', h_val, :for => id ),
            :class => 'lineitem' + (line_item+=1).to_s() ) +"\n"
        if line_item == line_size
          line_item = 0
          html += "<br />\n".html_safe
        end
      }
      html += "<br />\n".html_safe if line_size == 0 || ( values.size % line_size ) > 0
      column = object.class.columns_hash[method.to_s] if object
      text =
        ( column ?
          column.human_name :
          _(method.to_s.humanize)
        )
      label_html = self.class.content_tag 'label', text,
                                        :class => 'formlabel'
      control_html = self.class.content_tag 'div', html,
                                        :class => 'formfield type-radio '+
                                        'fieldgroup linesize'+line_size.to_s()

      self.class.content_tag 'div', label_html + control_html,
                                          :class => 'formfieldline'
    end

  end

  # create a form field structure (as if it were generated with
  # labelled_form_for), but with a customized control and label.
  #
  # If +field_id+ is not given, the underlying implementation will try to guess
  # it from +field_html+ using a regular expression. In this case, make sure
  # that the first ocurrance of id=['"]([^'"]*)['"] in +field_html+ if the one
  # you want (i.e. the correct id for the control )
  def labelled_form_field(label, field_html, field_id = nil)
    NoosferoFormBuilder::output_field(label, field_html, field_id)
  end

  alias_method :display_form_field, :labelled_form_field

  def labelled_fields_for(name, object = nil, options = {}, &proc)
    object ||= instance_variable_get("@#{name}")
    fields_for(name, object, { :builder => NoosferoFormBuilder }.merge(options), &proc)
  end

  def labelled_form_for(name, options = {}, &proc)
    form_for(name, { :builder => NoosferoFormBuilder }.merge(options), &proc)
  end

  def optional_field(profile, name, field_html = nil, only_required = false, &block)
    result = ""

    is_required = false
    if profile.required_fields.include?(name)
      is_required = true
    else
      return result if only_required
    end

    if block
      field_html ||= ''
      field_html += capture(&block)
    end

    if controller.action_name == 'signup' || controller.action_name == 'new_community' || (controller.controller_name == "enterprise_registration" && controller.action_name == 'index') || (controller.controller_name == 'home' && controller.action_name == 'index' && user.nil?)
      if profile.signup_fields.include?(name)
        result = field_html
      end
    else
      if profile.active_fields.include?(name)
        result = content_tag('div', field_html + profile_field_privacy_selector(profile, name), :class => 'field-with-privacy-selector')
      end
    end

    if is_required
      result = required(result)
    end

    if block
      concat(result)
    end

    result
  end

  def profile_field_privacy_selector(profile, name)
    return '' unless profile.public?
    content_tag('div', labelled_check_box(_('Public'), 'profile_data[fields_privacy]['+name+']', 'public', profile.public_fields.include?(name)), :class => 'field-privacy-selector')
  end

  def login_url
    options = Noosfero.url_options.merge({ :controller => 'account', :action => 'login' })
    url_for(options)
  end

  def base_url
    profile ? profile.top_url(request.scheme) : environment.top_url(request.scheme)
  end
  alias :top_url :base_url

  def helper_for_article(article)
    article_helper = ActionView::Base.new
    article_helper.controller = controller
    article_helper.extend ArticleHelper
    article_helper.extend Rails.application.routes.url_helpers
    begin
      class_name = article.class.name + 'Helper'
      klass = class_name.constantize
      article_helper.extend klass
    rescue
    end
    article_helper
  end

  def label_for_new_article(article)
    article_helper = helper_for_article(!article.nil? && !article.parent.nil? ? article.parent : article)
    article_helper.cms_label_for_new_children
  end

  def label_for_edit_article(article)
    article_helper = helper_for_article(article)
    article_helper.cms_label_for_edit
  end

  def label_for_clone_article(article)
    translated_types = {
      Folder => _('Folder'),
      Blog => _('Blog'),
      Event => _('Event'),
      Forum => _('Forum')
    }

    translated_type = translated_types[article.class] || _('Article')

    _('Clone %s') % translated_type
  end

  def add_rss_feed_to_head(title, url)
    content_for :feeds do
      tag(:link, :rel => 'alternate', :type => 'application/rss+xml', :title => title, :href => url_for(url))
    end
  end

  def page_title
    CGI.escapeHTML(
      (@page ? @page.title + ' - ' : '') +
      (@topic ? @topic.title + ' - ' : '') +
      (@section ? @section.title + ' - ' : '') +
      (@toc ? _('Online Manual') + ' - ' : '') +
      (controller.controller_name == 'chat' ? _('Chat') + ' - ' : '') +
      (profile ? profile.short_name : environment.name) +
      (@category ? " - #{@category.full_name}" : '')
    )
  end

  # DEPRECATED. Do not use this.
  def import_controller_stylesheets(options = {})
    stylesheet_import( "controller_"+ controller.controller_name(), options )
  end

  def link_to_email(email)
    javascript_tag('var array = ' + email.split('@').to_json + '; document.write("<a href=\'mailto:" + array.join("@") + "\'>" + array.join("@") +  "</a>")'.html_safe)
  end

  def stylesheet(*args)
    content_for(:head) { stylesheet_link_tag(*args) }
  end

  def article_to_html(article, options = {})
    options.merge!(:page => params[:npage])
    content = article.to_html(options)
    content = content.kind_of?(Proc) ? self.instance_exec(&content).html_safe : content.html_safe
    filter_html(content, article)
  end

  # Please, use link_to by default!
  # This method was created to work around to inexplicable
  # chain of problems when display_short_format was called
  # from Article model for an ArticleBlock.
  def reference_to_article(text, article, anchor=nil)
    if article.profile.domains.empty?
      href = "#{Noosfero.root}/#{article.url[:profile]}/"
    else
      href = "http://#{article.profile.domains.first.name}#{Noosfero.root}/"
    end
    href += article.url[:page].join('/')
    href += '#' + anchor if anchor
    content_tag('a', text, :href => href)
  end

  def display_short_format(article, options={})
    options[:comments_link] ||= true
    options[:read_more_link] ||= true
    html = content_tag('div',
             article.lead +
             content_tag('div',
               (options[:comments_link] ? link_to_comments(article) : '') +
               (options[:read_more_link] ? reference_to_article( _('Read more'), article) : ''),
               :class => 'read-more'
             ),
             :class => 'short-post'
           )
    html
  end

  def ui_icon(icon_class, extra_class = '')
    "<span class='ui-icon #{icon_class} #{extra_class}' style='float:left; margin-right:7px;'></span>".html_safe
  end

  def ui_button(label, url, html_options = {})
    link_to(label, url, html_options.merge(:class => 'ui_button fg-button'))
  end

  def ui_button_to_remote(label, options, html_options = {})
    link_to_remote(label, options, html_options.merge(:class => 'ui_button fg-button'))
  end

  def jquery_theme
    theme_option(:jquery_theme) || 'smoothness'
  end

  def ui_error(message)
    content_tag('div', ui_icon('ui-icon-alert') + message, :class => 'alert fg-state-error ui-state-error')
  end

  def ui_highlight(message)
    content_tag('div', ui_icon('ui-icon-info') + message, :class => 'alert fg-state-highlight ui-state-highlight')
  end

  def float_to_currency(value)
    number_to_currency(value, :unit => environment.currency_unit, :separator => environment.currency_separator, :delimiter => environment.currency_delimiter, :format => "%u %n")
  end

  def collapsed_item_icon
    "<span class='ui-icon ui-icon-circlesmall-plus' style='float:left;'></span>".html_safe
  end
  def expanded_item_icon
    "<span class='ui-icon ui-icon-circlesmall-minus' style='float:left;'></span>".html_safe
  end
  def leaf_item_icon
    "<span class='ui-icon ui-icon-arrow-1-e' style='float:left;'></span>".html_safe
  end

  def display_category_menu(block, categories, root = true)
    categories = categories.sort{|x,y| x.name <=> y.name}
    return "" if categories.blank?
    content_tag(:ul) do
      categories.map do |category|
        category_path = category.kind_of?(ProductCategory) ? {:controller => 'search', :action => 'assets', :asset => 'products', :product_category => category.id} : { :controller => 'search', :action => 'category_index', :category_path => category.explode_path }
        if category.display_in_menu?
          content_tag(:li) do
            if !category.is_leaf_displayable_in_menu?
              content_tag(:a, collapsed_item_icon, :href => "#", :id => "block_#{block.id}_category_#{category.id}", :class => "category-link-expand " + (root ? "category-root" : "category-no-root"), :onclick => "expandCategory(#{block.id}, #{category.id}); return false", :style => "display: none")
            else
              leaf_item_icon
            end +
            link_to(content_tag(:span, category.name, :class => "category-name"), category_path, :class => ("category-leaf" if category.is_leaf_displayable_in_menu?)) +
            content_tag(:div, :id => "block_#{block.id}_category_content_#{category.id}", :class => 'child-category') do
              display_category_menu(block, category.children, false)
            end
          end
        else
          ""
        end
      end.join.html_safe
    end +
    content_tag(:p) +
    (root ? javascript_tag("
      jQuery('.child-category').hide();
      jQuery('.category-link-expand').show();
      var expanded_icon = \"#{ expanded_item_icon }\";
      var collapsed_icon = \"#{ collapsed_item_icon }\";
      var category_expanded = { 'block' : 0, 'category' : 0 };
    ") : '')
  end

  def search_contents_menu
    links = [
      {s_('contents|More recent') => {:href => url_for({:controller => 'search', :action => 'contents', :filter => 'more_recent'})}},
      {s_('contents|More viewed') => {:href => url_for({:controller => 'search', :action => 'contents', :filter => 'more_popular'})}},
      {s_('contents|Most commented') => {:href => url_for({:controller => 'search', :action => 'contents', :filter => 'more_comments'})}}
    ]
    if logged_in?
      links.push(_('New content') => modal_options({:href => url_for({:controller => 'cms', :action => 'new', :profile => current_user.login, :cms => true})}))
    end

    link_to(content_tag(:span, _('Contents'), :class => 'icon-menu-articles'), {:controller => "search", :action => 'contents', :category_path => nil}, :id => 'submenu-contents') +
    popover_menu(_('Contents menu'),'',links,:class => 'up', :id => 'submenu-contents-trigger')
  end
  alias :browse_contents_menu :search_contents_menu

  def search_people_menu
     links = [
       {s_('people|More recent') => {:href => url_for({:controller => 'search', :action => 'people', :filter => 'more_recent'})}},
       {s_('people|More active') => {:href => url_for({:controller => 'search', :action => 'people', :filter => 'more_active'})}},
       {s_('people|More popular') => {:href => url_for({:controller => 'search', :action => 'people', :filter => 'more_popular'})}}
     ]
     if logged_in?
       links.push(_('My friends') => {:href => url_for({:profile => current_user.login, :controller => 'friends'})})
       links.push(_('Invite friends') => {:href => url_for({:profile => current_user.login, :controller => 'invite', :action => 'friends'})})
     end

    link_to(content_tag(:span, _('People'), :class => 'icon-menu-people'), {:controller => "search", :action => 'people', :category_path => ''}, :id => 'submenu-people') +
    popover_menu(_('People menu'),'',links,:class => 'up', :id => 'submenu-people-trigger')
  end
  alias :browse_people_menu :search_people_menu

  def search_communities_menu
     links = [
       {s_('communities|More recent') => {:href => url_for({:controller => 'search', :action => 'communities', :filter => 'more_recent'})}},
       {s_('communities|More active') => {:href => url_for({:controller => 'search', :action => 'communities', :filter => 'more_active'})}},
       {s_('communities|More popular') => {:href => url_for({:controller => 'search', :action => 'communities', :filter => 'more_popular'})}}
     ]
     if logged_in?
       links.push(_('My communities') => {:href => url_for({:profile => current_user.login, :controller => 'memberships'})})
       links.push(_('New community') => {:href => url_for({:profile => current_user.login, :controller => 'memberships', :action => 'new_community'})})
     end

    link_to(content_tag(:span, _('Communities'), :class => 'icon-menu-community'), {:controller => "search", :action => 'communities'}, :id => 'submenu-communities') +
    popover_menu(_('Communities menu'),'',links,:class => 'up', :id => 'submenu-communities-trigger')
  end
  alias :browse_communities_menu :search_communities_menu

  def pagination_links(collection, options={})
    options = {:previous_label => content_tag(:span, '&laquo; ', :class => 'previous-arrow') + _('Previous'), :next_label => _('Next') + content_tag(:span, ' &raquo;', :class => 'next-arrow'), :inner_window => 1, :outer_window => 0 }.merge(options)
    will_paginate(collection, options)
  end

  def render_environment_features(folder)
    result = ''
    environment.enabled_features.keys.each do |feature|
      file = Rails.root.join('app/views/shared', folder.to_s, "#{feature}.html.erb")
      if File.exists?(file)
        result << render(:file => file, :use_full_path => false)
      end
    end
    result
  end

  def manage_link(list, kind, title)
    if list.present?
      link_to_all = nil
      if list.count > 5
        list = list.first(5)
        link_to_all = link_to(content_tag('strong', _('See all')), :controller => 'memberships', :profile => user.identifier)
      end
      link = list.map do |element|
        link_to(content_tag('strong', _('<span>Manage</span> %s') % element.short_name(25)), element.admin_url, :class => "icon-menu-"+element.class.identification.underscore, :title => _('Manage %s') % element.short_name)
      end
      if link_to_all
        link << link_to_all
      end
      render :partial => "shared/manage_link", :locals => {:link => link, :kind => kind.to_s, :title => title}
    end
  end

  def manage_enterprises
    return '' unless user && user.environment.enabled?(:display_my_enterprises_on_user_menu)
    manage_link(user.enterprises, :enterprises, _('My enterprises')).to_s
  end

  def manage_communities
    return '' unless user && user.environment.enabled?(:display_my_communities_on_user_menu)
    administered_communities = user.communities.more_popular.select {|c| c.admins.include? user}
    manage_link(administered_communities, :communities, _('My communities')).to_s
  end

  def admin_link
    user.is_admin?(environment) ? link_to('<i class="icon-menu-admin"></i><strong>' + _('Administration') + '</strong>', environment.admin_url, :title => _("Configure the environment"), :class => 'admin-link') : ''
  end

  def usermenu_logged_in
    pending_tasks_count = ''
    count = user ? Task.to(user).pending.count : -1
    if count > 0
      pending_tasks_count = link_to(count.to_s, user.tasks_url, :id => 'pending-tasks-count', :title => _("Manage your pending tasks"))
    end

    (_("<span class='welcome'>Welcome,</span> %s") % link_to("<i style='background-image:url(#{user.profile_custom_icon(gravatar_default)})'></i><strong>#{user.identifier}</strong>", user.url, :id => "homepage-link", :title => _('Go to your homepage'))) +
    render_environment_features(:usermenu) +
    admin_link +
    manage_enterprises +
    manage_communities +
    link_to('<i class="icon-menu-ctrl-panel"></i><strong>' + _('Control panel') + '</strong>', user.admin_url, :class => 'ctrl-panel', :title => _("Configure your personal account and content")) +
    pending_tasks_count +
    link_to('<i class="icon-menu-logout"></i><strong>' + _('Logout') + '</strong>', { :controller => 'account', :action => 'logout'} , :id => "logout", :title => _("Leave the system"))
  end

  def limited_text_area(object_name, method, limit, text_area_id, options = {})
    content_tag(:div, [
      text_area(object_name, method, { :id => text_area_id, :onkeyup => "limited_text_area('#{text_area_id}', #{limit})" }.merge(options)),
      content_tag(:p, content_tag(:span, limit) + ' ' + _(' characters left'), :id => text_area_id + '_left'),
      content_tag(:p, _('Limit of characters reached'), :id => text_area_id + '_limit', :style => 'display: none')
    ].join, :class => 'limited-text-area')
  end

  def expandable_text_area(object_name, method, text_area_id, options = {})
    text_area(object_name, method, { :id => text_area_id, :onkeyup => "grow_text_area('#{text_area_id}')" }.merge(options))
  end

  def pluralize_without_count(count, singular, plural = nil)
    count == 1 ? singular : (plural || singular.pluralize)
  end

  def unique_with_count(list, connector = 'for')
    list.sort.inject(Hash.new(0)){|h,i| h[i] += 1; h }.collect{ |x, n| [n, connector, x].join(" ") }.sort
  end

  def comment_balloon(options = {}, &block)
    wrapper = content_tag(:div, capture(&block), :class => 'comment-balloon-content')
    (1..8).to_a.reverse.each { |i| wrapper = content_tag(:div, wrapper, :class => "comment-wrapper-#{i}") }
    classes = options.delete(:class) || options.delete("class") || ''
    concat(content_tag('div', wrapper + tag('br', :style => 'clear: both;'), { :class => 'comment-balloon ' + classes.to_s }.merge(options)))
  end

  def display_source_info(page)
    if !page.source.blank?
      source_url = link_to(page.source_name.blank? ? page.source : page.source_name, page.source)
    elsif page.reference_article
      source_url = link_to(page.reference_article.profile.name, page.reference_article.url)
    end
    content_tag(:div, _('Source: %s') % source_url, :id => 'article-source') unless source_url.nil?
  end

  def task_information(task)
    values = {}
    values.merge!({:requestor => link_to(task.requestor.name, task.requestor.url)}) if task.requestor
    values.merge!({:subject => content_tag('span', task.subject, :class=>'task_target')}) if task.subject
    values.merge!({:linked_subject => link_to(content_tag('span', task.linked_subject[:text], :class => 'task_target'), task.linked_subject[:url])}) if task.linked_subject
    values.merge!(task.information[:variables]) if task.information[:variables]
    task.information[:message] % values
  end

  def add_zoom_to_article_images
    add_zoom_to_images if environment.enabled?(:show_zoom_button_on_article_images)
  end

  def add_zoom_to_images
    stylesheet_link_tag('jquery.fancybox') +
    javascript_include_tag('jquery.fancybox.pack') +
    javascript_tag("apply_zoom_to_images(#{_('Zoom in').to_json})")
  end

  def render_dialog_error_messages(instance_name)
    render :partial => 'shared/dialog_error_messages', :locals => { :object_name => instance_name }
  end

  def report_abuse(profile, type, content=nil)
    return if !user || user == profile

    url = { :controller => 'profile',
            :action => 'report_abuse',
            :profile => profile.identifier }
    url.merge!({:content_type => content.class.name, :content_id => content.id}) if content
    text = content_tag('span', _('Report abuse'))
    klass = 'report-abuse-action'
    already_reported_message = _('You already reported this profile.')
    report_profile_message = _('Report this profile for abusive behaviour')

    if type == :button
      if user.already_reported?(profile)
        button(:alert, text, url, :class => klass+' disabled', :disabled => true, :title => already_reported_message)
      else
        button(:alert, text, url, :class => klass, :title => report_profile_message)
      end
    elsif type == :link
      if user.already_reported?(profile)
        content_tag('a', text, :class => klass + ' disabled button with-text icon-alert', :title => already_reported_message)
      else
        link_to(text, url, :class => klass + ' button with-text icon-alert', :title => report_profile_message)
      end
    elsif type == :comment_link
      (user.already_reported?(profile) ?
        content_tag('a', text, :class => klass + ' disabled comment-footer comment-footer-link', :title => already_reported_message) :
        link_to(text, url, :class => klass + ' comment-footer comment-footer-link', :title => report_profile_message)
      ) + content_tag('span', ' ', :class => 'comment-footer comment-footer-hide')
    end
  end

  def cache_timeout(key, timeout, &block)
    cache(key, { :expires_in => timeout }, &block)
  end

  def is_cache_expired?(key)
    !cache_store.fetch(ActiveSupport::Cache.expand_cache_key(key, :controller))
  end

  def render_tabs(tabs)
    titles = tabs.inject(''){ |result, tab| result << content_tag(:li, link_to(tab[:title], '#'+tab[:id]), :class => 'tab') }
    contents = tabs.inject(''){ |result, tab| result << content_tag(:div, tab[:content], :id => tab[:id]) }

    content_tag(:div, content_tag(:ul, titles) + raw(contents), :class => 'ui-tabs')
  end

  def delete_article_message(article)
    CGI.escapeHTML(
      if article.folder?
        _("Are you sure that you want to remove the folder \"%s\"? Note that all the items inside it will also be removed!") % article.name
      else
        _("Are you sure that you want to remove the item \"%s\"?") % article.name
      end
    )
  end

  def expirable_link_to(expired, content, url, options = {})
    if expired
      options[:class] = (options[:class] || '') + ' disabled'
      content_tag('a', '&nbsp;'+content_tag('span', content), options)
    else
      if options[:modal]
        options.delete(:modal)
        modal_link_to content, url, options
      else
        link_to content, url, options
      end
    end
  end

  def content_remove_spread(content)
    !content.public? || content.folder? || (profile == user && user.communities.blank? && !environment.portal_enabled)
  end

  def remove_content_button(action, content)
    method_name = "content_remove_#{action.to_s}"
    plugin_condition = @plugins.dispatch(method_name, content).include?(true)
    begin
      core_condition = self.send(method_name, content)
    rescue NoMethodError
      core_condition = false
    end
    core_condition || plugin_condition
  end

  def template_options(kind, field_name)
    templates = environment.send(kind).templates
    return '' if templates.count == 0
    return hidden_field_tag("#{field_name}[template_id]", templates.first.id) if templates.count == 1

    radios = templates.map do |template|
      content_tag('li', labelled_radio_button(link_to(template.name, template.url, :target => '_blank'), "#{field_name}[template_id]", template.id, environment.is_default_template?(template)))
    end.join("\n")

    content_tag('div', content_tag('label', _('Profile organization'), :for => 'template-options', :class => 'formlabel') +
      content_tag('p', _('Your profile will be created according to the selected template. Click on the options to view them.'), :style => 'margin: 5px 15px;padding: 0px 10px;') +
      content_tag('ul', radios, :style => 'list-style: none; padding-left: 20px; margin-top: 0.5em;'),
      :id => 'template-options',
      :style => 'margin-top: 1em'
    )
  end

  def expirable_content_reference(content, action, text, url, options = {})
    reason = @plugins.dispatch("content_expire_#{action.to_s}", content).first
    options[:title] = reason
    expirable_link_to reason.present?, text, url, options
  end

  def expirable_button(content, action, text, url, options = {})
    options[:class] = ["button with-text icon-#{action.to_s}", options[:class]].compact.join(' ')
    expirable_content_reference content, action, text, url, options
  end

  def expirable_comment_link(content, action, text, url, options = {})
    options[:class] = ["comment-footer comment-footer-link comment-footer-hide", options[:class]].compact.join(' ')
    expirable_content_reference content, action, text, url, options
  end

  def error_messages_for(*args)
    options = args.pop if args.last.is_a?(Hash)
    errors = []
    args.each do |name|
      object = instance_variable_get("@#{name}")
      object.errors.full_messages.each do |msg|
        errors << msg
      end if object
    end
    return '' if errors.empty?

    content_tag(:div, :class => 'errorExplanation', :id => 'errorExplanation') do
      content_tag(:h2, _('Errors while saving')) +
      content_tag(:ul) do
        errors.map { |err| content_tag(:li, err) }.join
      end
    end
  end

  def private_profile_partial_parameters
    if profile.person?
      @action = :add_friend
      @message = _("The content here is available to %s's friends only.") % profile.short_name
    else
      @action = :join
      @message = _('The contents in this profile is available to members only.')
    end
    @no_design_blocks = true
  end

  def filter_html(html, source)
    if @plugins && source && source.has_macro?
      html = convert_macro(html, source) unless @plugins.enabled_macros.blank?
      #TODO This parse should be done through the macro infra, but since there
      #     are old things that do not support it we are keeping this hot spot.
      html = @plugins.pipeline(:parse_content, html, source).first
    end
    html && html.html_safe
  end

  def convert_macro(html, source)
    doc = Nokogiri::HTML.fragment html
    #TODO This way is more efficient but do not support macro inside of
    #     macro. You must parse them from the inside-out in order to enable
    #     that.
    doc.css('.macro').each do |macro|
      macro_name = macro['data-macro']
      result = @plugins.parse_macro(macro_name, macro, source)
      macro.inner_html = result.kind_of?(Proc) ? self.instance_exec(&result) : result
    end
    doc.to_html
  end

  def default_folder_for_image_upload(profile)
    default_folder = profile.folders.find_by_type('Gallery')
    default_folder = profile.folders.find_by_type('Folder') if default_folder.nil?
    default_folder
  end

  def content_id_to_str(content)
    content.nil? ? '' : content.id.to_s
  end

  def display_article_versions(article, version = nil)
    content_tag('ul', article.versions.map {|v| link_to("r#{v.version}", @page.url.merge(:version => v.version))})
  end

  def search_input_with_suggestions(name, asset, default, options = {})
    text_field_tag name, default, options.merge({:class => 'search-input-with-suggestions', 'data-asset' => asset})
  end

  def profile_suggestion_profile_connections(suggestion)
    profiles = suggestion.profile_connections.first(4).map do |profile|
      link_to(profile_image(profile, :icon, :title => profile.name), profile.url, :class => 'profile-suggestion-connection-icon')
    end

    controller_target = suggestion.suggestion_type == 'Person' ? :friends : :memberships
    profiles << link_to("<big> +#{suggestion.profile_connections.count - 4}</big>", :controller => controller_target, :action => :connections, :id => suggestion.suggestion_id) if suggestion.profile_connections.count > 4

    if profiles.present?
      content_tag(:div, profiles.join , :class => 'profile-connections')
    else
      ''
    end
  end

  def profile_suggestion_tag_connections(suggestion)
    tags = suggestion.tag_connections.first(4).map do |tag|
      tag.name + ', '
    end
    last_tag = tags.pop
    tags << last_tag.strip.chop if last_tag.present?
    title = tags.join

    controller_target = suggestion.suggestion_type == 'Person' ? :friends : :memberships
    tags << ' ' + link_to('...', {:controller => controller_target, :action => :connections, :id => suggestion.suggestion_id}, :class => 'more-tag-connections', :title => _('See all connections')) if suggestion.tag_connections.count > 4

    if tags.present?
      content_tag(:div, tags.join, :class => 'tag-connections', :title => title)
    else
      ''
    end
  end

  def labelled_colorpicker_field(human_name, object_name, method, options = {})
    options[:id] ||= 'text-field-' + FormsHelper.next_id_number
    content_tag('label', human_name, :for => options[:id], :class => 'formlabel') +
    colorpicker_field(object_name, method, options.merge(:class => 'colorpicker_field'))
  end

  def colorpicker_field(object_name, method, options = {})
    text_field(object_name, method, options.merge(:class => 'colorpicker_field'))
  end

  def fullscreen_buttons(itemId)
    content="
      <script>fullscreenPageLoad('#{itemId}')</script>
    "
    content+=content_tag('a', content_tag('span',_("Full screen")),
    { :id=>"fullscreen-btn",
      :onClick=>"toggle_fullwidth('#{itemId}')",
      :class=>"button with-text icon-fullscreen",
      :href=>"#",
      :title=>_("Go to full screen mode")
    })

    content+=content_tag('a', content_tag('span',_("Exit full screen")),
    { :style=>"display: none;",
      :id=>"exit-fullscreen-btn",
      :onClick=>"toggle_fullwidth('#{itemId}')",
      :class=>"button with-text icon-fullscreen",
      :href=>"#",
      :title=>_("Exit full screen mode")
    })
  end

end
