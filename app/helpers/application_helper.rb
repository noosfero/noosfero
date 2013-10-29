require 'redcloth'

# Methods added to this helper will be available to all templates in the
# application.
module ApplicationHelper

  include PermissionNameHelper

  include LightboxHelper

  include ThickboxHelper

  include ColorboxHelper

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
    @controller.send(:profile)
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
    concat(content_tag('div', capture(&block) + tag('br', :style => 'clear: left;'), options))
  end

  VIEW_EXTENSIONS = %w[.rhtml .html.erb]

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

    VIEW_EXTENSIONS.each do |ext|
      path = defined?(params) && params[:controller] ? File.join(view_path, params[:controller], search_name+ext) : File.join(view_path, search_name+ext)
      return name if File.exists?(File.join(path))
    end

    partial_for_class_in_view_path(klass.superclass, view_path, prefix, suffix)
  end

  def partial_for_class(klass, prefix=nil, suffix=nil)
    raise ArgumentError, 'No partial for object. Is there a partial for any class in the inheritance hierarchy?' if klass.nil?
    name = klass.name.underscore
    @controller.view_paths.each do |view_path|
      partial = partial_for_class_in_view_path(klass, view_path, prefix, suffix)
      return partial if partial
    end

    raise ArgumentError, 'No partial for object. Is there a partial for any class in the inheritance hierarchy?'
  end

  def view_for_profile_actions(klass)
    raise ArgumentError, 'No profile actions view for this class.' if klass.nil?

    name = klass.name.underscore
    VIEW_EXTENSIONS.each do |ext|
      return "blocks/profile_info_actions/"+name+ext if File.exists?(File.join(RAILS_ROOT, 'app', 'views', 'blocks', 'profile_info_actions', name+ext))
    end

    view_for_profile_actions(klass.superclass)
  end

  def user
    @controller.send(:user)
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
        if File.exists?(File.join(RAILS_ROOT, 'public', filename))
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
        if (session[:theme])
          session[:theme]
        else
          # utility for developers: set the theme to 'random' in development mode and
          # you will get a different theme every request. This is interesting for
          # testing
          if ENV['RAILS_ENV'] == 'development' && environment.theme == 'random'
            @random_theme ||= Dir.glob('public/designs/themes/*').map { |f| File.basename(f) }.rand
            @random_theme
          elsif ENV['RAILS_ENV'] == 'development' && params[:theme] && File.exists?(File.join(Rails.root, 'public/designs/themes', params[:theme]))
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

  def theme_include(template)
    ['.rhtml', '.html.erb'].each do |ext|
      file = (RAILS_ROOT + '/public' + theme_path + '/' + template  + ext)
      if File.exists?(file)
        return render :file => file, :use_full_path => false
      end
    end
    nil
  end

  def theme_favicon
    return '/designs/themes/' + current_theme + '/favicon.ico' if profile.nil? || profile.theme.nil?
    if File.exists?(File.join(RAILS_ROOT, 'public', theme_path, 'favicon.ico'))
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
    theme_include('site_title')
  end

  def theme_header
    theme_include('header')
  end

  def theme_footer
    theme_include('footer')
  end

  def theme_extra_navigation
    theme_include('navigation')
  end

  def is_testing_theme
    !@controller.session[:theme].nil?
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
          '/images/icons-app/person-'+ size.to_s() +'.png'
        end
      filename = default_or_themed_icon(icon)
    end
    return_mimetype ? [filename, mimetype] : filename
  end

  def default_or_themed_icon(icon)
    if File.exists?(File.join(Rails.root, 'public', theme_path, icon))
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
      icons = profile.product_categories.map{ |c| c.size > 1 ? c[1] : nil }.
        compact.uniq.map do |c|
          cat_name = c.gsub( /[-_\s,.;'"]+/, '_' )
          cat_icon = "/images/icons-cat/#{cat_name}.png"
          if ! File.exists? RAILS_ROOT.to_s() + '/public/' + cat_icon
            cat_icon = '/images/icons-cat/undefined.png'
          end
          content_tag('span',
            content_tag( 'span', c ),
            :title => c,
            :class => 'product-cat-icon cat_icon_' + cat_name,
            :style => "background-image:url(#{cat_icon})"
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
      return instance_eval(&content)
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
                                   (environment.enabled?(:show_balloon_with_profile_links_when_clicked) ? link_to( content_tag( 'span', _('Profile links')), '#', :onclick => "toggleSubmenu(this, '#{profile.short_name}', #{links.to_json}); return false", :class => "menu-submenu-trigger #{trigger_class}", :url => url) : "") +
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

  def gravatar_url_for(email, options = {})
    # Ta dando erro de roteamento
    default = theme_option['gravatar'] || NOOSFERO_CONF['gravatar'] || nil
    url_for( { :gravatar_id => Digest::MD5.hexdigest(email.to_s),
               :host => 'www.gravatar.com',
               :protocol => 'http://',
               :only_path => false,
               :controller => 'avatar.php',
               :d => default
             }.merge(options) )
  end

  def str_gravatar_url_for(email, options = {})
    default = theme_option['gravatar'] || NOOSFERO_CONF['gravatar'] || nil
    url = 'http://www.gravatar.com/avatar.php?gravatar_id=' +
           Digest::MD5.hexdigest(email.to_s)
    {
      :only_path => false,
      :d => default
    }.merge(options).each { |k,v|
      url += ( '&%s=%s' % [ k,v ] )
    }
    url
  end

  def gravatar_profile_url(email)
    'http://www.gravatar.com/'+ Digest::MD5.hexdigest(email.to_s)
  end

  attr_reader :environment
  def select_categories(object_name, title=nil, title_size=4)
    return nil if environment.enabled?(:disable_categories)
    if title.nil?
      title = _('Categories')
    end

    object = instance_variable_get("@#{object_name}")

    result = content_tag 'h'+title_size.to_s(), title
    result << javascript_tag( 'function open_close_cat( link ) {
      var div = link.parentNode.getElementsByTagName("div")[0];
      var end = function(){
        if ( div.style.display == "none" ) {
          this.link.className="button icon-button icon-down"
        } else {
          this.link.className="button icon-button icon-up-red"
        }
      }
      Effect.toggle( div, "slide", { link:link, div:div, afterFinish:end } )
    }')
    environment.top_level_categories.select{|i| !i.children.empty?}.each do |toplevel|
      next unless object.accept_category?(toplevel)
      # FIXME
      ([toplevel] + toplevel.children_for_menu).each do |cat|
        if cat.top_level?
          result << '<div class="categorie_box">'.html_safe
          result << icon_button( :down, _('open'), '#', :onclick => 'open_close_cat(this); return false' )
          result << content_tag('h5', toplevel.name)
          result << '<div style="display:none"><ul class="categories">'.html_safe
        else
          checkbox_id = "#{object_name}_#{cat.full_name.downcase.gsub(/\s+|\//, '_')}"
          result << content_tag('li', labelled_check_box(
                      cat.full_name_without_leading(1, " &rarr; "),
                      "#{object_name}[category_ids][]", cat.id,
                      object.category_ids.include?(cat.id), :id => checkbox_id,
                      :onchange => 'this.parentNode.className=(this.checked?"cat_checked":"")' ),
                    :class => ( object.category_ids.include?(cat.id) ? 'cat_checked' : '' ) ) + "\n"
        end
      end
      result << '</ul></div></div>'.html_safe
    end

    content_tag('div', result)
  end

  def theme_option(opt = nil)
    conf = RAILS_ROOT.to_s() +
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
    else #opt == 'lightbox_link' is default
      lightbox_link_to '<span class="icon-menu-search"></span>'+ _('Search'), {
                       :controller => 'search',
                       :action => 'popup',
                       :category_path => (@category ? @category.explode_path : []) },
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
      if File.exists? RAILS_ROOT.to_s() +'/public'+ file
        html << javascript_src_tag( file, {} )
      else
        html << '<!-- Not included: '+ file +' -->'
      end
    end
    html.join "\n"
  end

  def theme_javascript_ng
    script = File.join(theme_path, 'theme.js')
    if File.exists?(File.join(Rails.root, 'public', script))
      javascript_include_tag script
    else
      nil
    end
  end

  def file_field_or_thumbnail(label, image, i)
    display_form_field label, (
      render :partial => (image && image.valid? ? 'shared/show_thumbnail' : 'shared/change_image'),
      :locals => { :i => i, :image => image }
      )
  end

  def rolename_for(profile, resource)
    role = profile.role_assignments.find_by_resource_id(resource.id).role
    content_tag('span', role.name, :style => "color: #{role_color(role, resource.environment.id)}")
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

    def self.output_field(text, field_html, field_id = nil)
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
      column = object.class.columns_hash[method.to_s]
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

  def labelled_form_for(name, object = nil, options = {}, &proc)
    object ||= instance_variable_get("@#{name}")
    form_for(name, object, { :builder => NoosferoFormBuilder }.merge(options), &proc)
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

    if controller.action_name == 'signup' || controller.action_name == 'new_community' || (controller.controller_name == "enterprise_registration" && controller.action_name == 'index')
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
    environment.top_url
  end

  def helper_for_article(article)
    article_helper = ActionView::Base.new
    article_helper.controller = controller
    article_helper.extend ArticleHelper
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

  def add_rss_feed_to_head(title, url)
    content_for :feeds do
      tag(:link, :rel => 'alternate', :type => 'application/rss+xml', :title => title, :href => url_for(url))
    end
  end

  def page_title
    (@page ? @page.title + ' - ' : '') +
    (profile ? profile.short_name + ' - ' : '') +
    (@topic ? @topic.title + ' - ' : '') +
    (@section ? @section.title + ' - ' : '') +
    (@toc ? _('Online Manual') + ' - ' : '') +
    (@controller.controller_name == 'chat' ? _('Chat') + ' - ' : '') +
    environment.name +
    (@category ? " - #{@category.full_name}" : '')
  end

  # DEPRECATED. Do not use this·
  def import_controller_stylesheets(options = {})
    stylesheet_import( "controller_"+ @controller.controller_name(), options )
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
    content = content.kind_of?(Proc) ? self.instance_eval(&content).html_safe : content.html_safe
    filter_html(content, article)
  end

  # Please, use link_to by default!
  # This method was created to work around to inexplicable
  # chain of problems when display_short_format was called
  # from Article model for an ArticleBlock.
  def reference_to_article(text, article, anchor=nil)
    if article.profile.domains.empty?
      href = "/#{article.url[:profile]}/"
    else
      href = "http://#{article.profile.domains.first.name}/"
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

  def colorpicker_field(object_name, method, options = {})
    text_field(object_name, method, options.merge(:class => 'colorpicker_field'))
  end

  def colorpicker_field_tag(name, value = nil, options = {})
    text_field_tag(name, value, options.merge(:class => 'colorpicker_field'))
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
    theme_option(:jquery_theme) || 'smoothness_mod'
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
    content_tag(:ul,
      categories.map do |category|
        category_path = category.kind_of?(ProductCategory) ? {:controller => 'search', :action => 'assets', :asset => 'products', :product_category => category.id} : { :controller => 'search', :action => 'category_index', :category_path => category.explode_path }
        category.display_in_menu? ?
        content_tag(:li,
          ( !category.is_leaf_displayable_in_menu? ? content_tag(:a, collapsed_item_icon, :href => "#", :id => "block_#{block.id}_category_#{category.id}", :class => 'category-link-expand ' + (root ? 'category-root' : 'category-no-root'), :onclick => "expandCategory(#{block.id}, #{category.id}); return false", :style => 'display: none') : leaf_item_icon) +
          link_to(content_tag(:span, category.name, :class => 'category-name'), category_path, :class => ("category-leaf" if category.is_leaf_displayable_in_menu?)) +
          content_tag(:div, display_category_menu(block, category.children, false), :id => "block_#{block.id}_category_content_#{category.id}", :class => 'child-category')
        ) : ''
      end
    ) +
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
      links.push(_('New content') => colorbox_options({:href => url_for({:controller => 'cms', :action => 'new', :profile => current_user.login, :cms => true})}))
    end

    link_to(content_tag(:span, _('Contents'), :class => 'icon-menu-articles'), {:controller => "search", :action => 'contents', :category_path => ''}, :id => 'submenu-contents') +
    link_to(content_tag(:span, _('Contents menu')), '#', :onclick => "toggleSubmenu(this,'',#{links.to_json}); return false", :class => 'menu-submenu-trigger up', :id => 'submenu-contents-trigger')
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
    link_to(content_tag(:span, _('People menu')), '#', :onclick => "toggleSubmenu(this,'',#{links.to_json}); return false", :class => 'menu-submenu-trigger up', :id => 'submenu-people-trigger')
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
    link_to(content_tag(:span, _('Communities menu')), '#', :onclick => "toggleSubmenu(this,'',#{links.to_json}); return false", :class => 'menu-submenu-trigger up', :id => 'submenu-communities-trigger')
  end
  alias :browse_communities_menu :search_communities_menu

  def pagination_links(collection, options={})
    options = {:previous_label => '&laquo; ' + _('Previous'), :next_label => _('Next') + ' &raquo;'}.merge(options)
    will_paginate(collection, options)
  end

  def render_environment_features(folder)
    result = ''
    environment.enabled_features.keys.each do |feature|
      file = File.join(@controller.view_paths.last, 'shared', folder.to_s, "#{feature}.rhtml")
      if File.exists?(file)
        result << render(:file => file, :use_full_path => false)
      end
    end
    result
  end

  def manage_link(list, kind)
    if list.present?
      link_to_all = nil
      if list.count > 5
        list = list.first(5)
        link_to_all = link_to(content_tag('strong', _('See all')), :controller => 'memberships', :profile => current_user.login)
      end
      link = list.map do |element|
        link_to(content_tag('strong', [_('<span>Manage</span> %s') % element.short_name(25)]), @environment.top_url + "/myprofile/#{element.identifier}", :class => "icon-menu-"+element.class.identification.underscore, :title => [_('Manage %s') % element.short_name])
      end
      if link_to_all
        link << link_to_all
      end
      render :partial => "shared/manage_link", :locals => {:link => link, :kind => kind.to_s}
    end
  end

  def manage_enterprises
    return if not user
    manage_link(user.enterprises, :enterprises)
  end

  def manage_communities
    return if not user
    administered_communities = user.communities.more_popular.select {|c| c.admins.include? user}
    manage_link(administered_communities, :communities)
  end

  def usermenu_logged_in
    pending_tasks_count = ''
    count = user ? Task.to(user).pending.count : -1
    if count > 0
      pending_tasks_count = link_to(count.to_s, @environment.top_url + '/myprofile/{login}/tasks', :id => 'pending-tasks-count', :title => _("Manage your pending tasks"))
    end

    (_("<span class='welcome'>Welcome,</span> %s") % link_to('<i></i><strong>{login}</strong>', @environment.top_url + '/{login}', :id => "homepage-link", :title => _('Go to your homepage'))) +
    render_environment_features(:usermenu) +
    link_to('<i class="icon-menu-admin"></i><strong>' + _('Administration') + '</strong>', @environment.top_url + '/admin', :id => "controlpanel", :title => _("Configure the environment"), :class => 'admin-link', :style => 'display: none') +
    manage_enterprises.to_s +
    manage_communities.to_s +
    link_to('<i class="icon-menu-ctrl-panel"></i><strong>' + _('Control panel') + '</strong>', @environment.top_url + '/myprofile/{login}', :id => "controlpanel", :title => _("Configure your personal account and content")) +
    pending_tasks_count +
    link_to('<i class="icon-menu-logout"></i><strong>' + _('Logout') + '</strong>', { :controller => 'account', :action => 'logout'} , :id => "logout", :title => _("Leave the system"))
  end

  def limited_text_area(object_name, method, limit, text_area_id, options = {})
    content_tag(:div, [
      text_area(object_name, method, { :id => text_area_id, :onkeyup => "limited_text_area('#{text_area_id}', #{limit})" }.merge(options)),
      content_tag(:p, content_tag(:span, limit) + ' ' + _(' characters left'), :id => text_area_id + '_left'),
      content_tag(:p, _('Limit of characters reached'), :id => text_area_id + '_limit', :style => 'display: none')
    ], :class => 'limited-text-area')
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

  #FIXME Use time_ago_in_words instead of this method if you're using Rails 2.2+
  def time_ago_as_sentence(from_time, include_seconds = false)
    to_time = Time.now
    from_time = from_time.to_time if from_time.respond_to?(:to_time)
    to_time = to_time.to_time if to_time.respond_to?(:to_time)
    distance_in_minutes = (((to_time - from_time).abs)/60).round
    distance_in_seconds = ((to_time - from_time).abs).round
    case distance_in_minutes
      when 0..1
        return (distance_in_minutes == 0) ? _('less than a minute') : _('1 minute') unless include_seconds
        case distance_in_seconds
          when 0..4   then _('less than 5 seconds')
          when 5..9   then _('less than 10 seconds')
          when 10..19 then _('less than 20 seconds')
          when 20..39 then _('half a minute')
          when 40..59 then _('less than a minute')
          else             _('1 minute')
        end

      when 2..44           then _('%{distance} minutes ago') % { :distance => distance_in_minutes }
      when 45..89          then _('about 1 hour ago')
      when 90..1439        then _('about %{distance} hours ago') % { :distance => (distance_in_minutes.to_f / 60.0).round }
      when 1440..2879      then _('1 day ago')
      when 2880..10079     then _('%{distance} days ago') % { :distance => (distance_in_minutes / 1440).round }
      else                      show_time(from_time)
    end
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
    values.merge!({:requestor => link_to(task.requestor.name, task.requestor.public_profile_url)}) if task.requestor
    values.merge!({:subject => content_tag('span', task.subject, :class=>'task_target')}) if task.subject
    values.merge!({:linked_subject => link_to(content_tag('span', task.linked_subject[:text], :class => 'task_target'), task.linked_subject[:url])}) if task.linked_subject
    values.merge!(task.information[:variables]) if task.information[:variables]
    task.information[:message] % values
  end

  def add_zoom_to_article_images
    add_zoom_to_images if environment.enabled?(:show_zoom_button_on_article_images)
  end

  def add_zoom_to_images
    stylesheet_link_tag('fancybox') +
    javascript_include_tag('jquery.fancybox-1.3.4.pack') +
    javascript_tag("jQuery(function($) {
      $(window).load( function() {
        $('#article .article-body img').each( function(index) {
          var original = original_image_dimensions($(this).attr('src'));
          if ($(this).width() < original['width'] || $(this).height() < original['height']) {
            $(this).wrap('<div class=\"zoomable-image\" />');
            $(this).parent('.zoomable-image').attr('style', $(this).attr('style'));
            $(this).attr('style', '');
            $(this).after(\'<a href=\"' + $(this).attr('src') + '\" class=\"zoomify-image\"><span class=\"zoomify-text\">%s</span></a>');
          }
        });
        $('.zoomify-image').fancybox();
      });
    });" % _('Zoom in'))
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

  def jquery_token_input_messages_json(hintText = _('Type in an keyword'), noResultsText = _('No results'), searchingText = _('Searching...'))
    "hintText: '#{hintText}', noResultsText: '#{noResultsText}', searchingText: '#{searchingText}'"
  end

  def delete_article_message(article)
    if article.folder?
      _("Are you sure that you want to remove the folder \"#{article.name}\"? Note that all the items inside it will also be removed!")
    else
      _("Are you sure that you want to remove the item \"#{article.name}\"?")
    end
  end

  def expirable_link_to(expired, content, url, options = {})
    if expired
      options[:class] = (options[:class] || '') + ' disabled'
      content_tag('a', '&nbsp;'+content_tag('span', content), options)
    else
      link_to content, url, options
    end
  end

  def remove_content_button(action)
    @plugins.dispatch("content_remove_#{action.to_s}", @page).include?(true)
  end

  def template_options(klass, field_name)
    templates = klass.templates(environment)
    return '' if templates.count == 0
    return hidden_field_tag("#{field_name}[template_id]", templates.first.id) if templates.count == 1

    counter = 0
    radios = templates.map do |template|
      counter += 1
      content_tag('li', labelled_radio_button(link_to(template.name, template.url, :target => '_blank'), "#{field_name}[template_id]", template.id, counter==1))
    end.join("\n")

    content_tag('div', content_tag('label', _('Profile organization'), :for => 'template-options', :class => 'formlabel') +
      content_tag('p', _('Your profile will be created according to the selected template. Click on the options to view them.'), :style => 'margin: 5px 15px;padding: 0px 10px;') +
      content_tag('ul', radios, :style => 'list-style: none; padding-left: 20px; margin-top: 0.5em;'),
      :id => 'template-options',
      :style => 'margin-top: 1em'
    )
  end

  def token_input_field_tag(name, element_id, search_action, options = {}, text_field_options = {}, html_options = {})
    options[:min_chars] ||= 3
    options[:hint_text] ||= _("Type in a search term")
    options[:no_results_text] ||= _("No results")
    options[:searching_text] ||= _("Searching...")
    options[:search_delay] ||= 1000
    options[:prevent_duplicates] ||=  true
    options[:backspace_delete_item] ||= false
    options[:focus] ||= false
    options[:avoid_enter] ||= true
    options[:on_result] ||= 'null'
    options[:on_add] ||= 'null'
    options[:on_delete] ||= 'null'
    options[:on_ready] ||= 'null'

    result = text_field_tag(name, nil, text_field_options.merge(html_options.merge({:id => element_id})))
    result += javascript_tag("jQuery('##{element_id}')
      .tokenInput('#{url_for(search_action)}', {
        minChars: #{options[:min_chars].to_json},
        prePopulate: #{options[:pre_populate].to_json},
        hintText: #{options[:hint_text].to_json},
        noResultsText: #{options[:no_results_text].to_json},
        searchingText: #{options[:searching_text].to_json},
        searchDelay: #{options[:serach_delay].to_json},
        preventDuplicates: #{options[:prevent_duplicates].to_json},
        backspaceDeleteItem: #{options[:backspace_delete_item].to_json},
        queryParam: #{name.to_json},
        tokenLimit: #{options[:token_limit].to_json},
        onResult: #{options[:on_result]},
        onAdd: #{options[:on_add]},
        onDelete: #{options[:on_delete]},
        onReady: #{options[:on_ready]},
      });
    ")
    result += javascript_tag("jQuery('##{element_id}').focus();") if options[:focus]
    if options[:avoid_enter]
      result += javascript_tag("jQuery('#token-input-#{element_id}')
                    .live('keydown', function(event){
                    if(event.keyCode == '13') return false;
                    });")
    end
    result
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

  def private_profile_partial_parameters
    if profile.person?
      @action = :add_friend
      @message = _("The content here is available to %s's friends only.") % profile.short_name
    else
      @action = :join
      @message = _('The contents in this community is available to members only.')
    end
    @no_design_blocks = true
  end

  def filter_html(html, source)
    if @plugins
      html = convert_macro(html, source)
      #TODO This parse should be done through the macro infra, but since there
      #     are old things that do not support it we are keeping this hot spot.
      html = @plugins.pipeline(:parse_content, html, source).first
    end
    html
  end

  def convert_macro(html, source)
    doc = Hpricot(html)
    #TODO This way is more efficient but do not support macro inside of
    #     macro. You must parse them from the inside-out in order to enable
    #     that.
    doc.search('.macro').each do |macro|
      macro_name = macro['data-macro']
      result = @plugins.parse_macro(macro_name, macro, source)
      macro.inner_html = result.kind_of?(Proc) ? self.instance_eval(&result) : result
    end
    doc.html
  end

  def default_folder_for_image_upload(profile)
    default_folder = profile.folders.find_by_type('Gallery')
    default_folder = profile.folders.find_by_type('Folder') if default_folder.nil?
    default_folder
  end

  def content_id_to_str(content)
    content.nil? ? '' : content.id.to_s
  end

end
