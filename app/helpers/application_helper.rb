# Methods added to this helper will be available to all templates in the
# application.
module ApplicationHelper

  include PermissionNameHelper

  include UrlHelper

  include PartialsHelper

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

  include PluginsHelper

  include ButtonsHelper

  include ProfileImageHelper

  include ThemeLoaderHelper

  include TaskHelper

  include TasksHelper

  include MembershipsHelper

  include StyleHelper

  include CustomFieldsHelper
  include TooltipHelper

  include ProfileSelectorHelper

  include EventsHelper

  include SensitiveContentHelper

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
    link_name ||= font_awesome(:help, _('Help'))

    @help_message_id ||= 1
    help_id = "help_message_#{@help_message_id}"

    if content.nil?
      return '' if block.nil?
      content = capture(&block)
    end

    options[:class] = '' if ! options[:class]
    options[:class] += ' button icon-help' # with-text

    # TODO: implement this button, and add style='display: none' to the help
    # message DIV
    button = link_to_function(content_tag('span', link_name), "Element.show('#{help_id}')", options )
    close_button = content_tag("div", link_to_function(_("Close"), "Element.hide('#{help_id}')", :class => 'close_help_button'))

    text = content_tag('div', button + content_tag('div', content_tag('div', content.html_safe) + close_button, :class => 'help_message', :id => help_id, :style => 'display: none;'), :class => 'help_box')

    unless block.nil?
      concat(text)
    end

    text
  end

  # TODO: do something more useful here
  # TODO: test this helper
  # TODO: add an icon?
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

  def link_to_homepage(text, profile, options = {})
    link_to text, profile.url, options
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

  def icon(icon_name, html_options = {})
    the_class = "button #{icon_name}"
    if html_options.has_key?(:class)
      the_class << ' ' << html_options[:class]
    end
    content_tag('div', '', html_options.merge(:class => the_class))
  end

  def icon_button(type, text, url, html_options = {})
    css_class = "icon-button icon-#{type}"
    if html_options.has_key?(:class)
      css_class << ' ' << html_options[:class]
    end
    link_to(content_tag('span', text), url, html_options.merge(class: css_class, title: text))
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
    from_theme_include(session[:theme] || environment.theme, template, options)
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
    if File.exists?(File.join(Rails.root, 'public', theme_path, 'favicon.ico'))
      '/designs/themes/' + profile.theme + '/favicon.ico'
    else
      favicon = profile.articles.find_by path: 'favicon.ico'
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

  def theme_user
    @theme_user ||= theme_include 'user'
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
    !controller.session[:user_theme].nil?
  end

  def theme_owner
    Theme.find(current_theme).owner.identifier
  end

  def popover_menu(title, menu_title, links,html_options = {})
    html_options[:class] = "" unless html_options[:class]
    html_options[:class] << " menu-submenu-trigger"
    html_options[:onclick] = "toggleSubmenu(this, '#{menu_title}', #{CGI::escapeHTML(links.to_json)}); return false".html_safe
    link_to(content_tag(:span, title), '#', html_options)
  end

  attr_reader :environment

  def select_categories(object_name, title=nil, title_size=4, kind=:categories)
    return nil if environment.enabled?(:disable_categories)
    if title.nil?
      title = _('Categories')
    end

    @object = instance_variable_get("@#{object_name}")
    @categories = environment.send("top_level_#{kind}")
    selected_categories = @object.send(kind).where(type: kind.to_s.singularize.camelize)

    render :partial => 'shared/select_categories_top', :locals => { :object_name => object_name, :title => title, :title_size => title_size, :multiple => true, :categories_selected => selected_categories, :kind => kind }, :layout => false
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

  def theme_simple_search_menu_search
    s = _('Search...')
    "<form action=\"#{url_for(:controller => 'search', :action => 'index')}\" id=\"simple-search\" class=\"focus-out\""+
    ' help="'+_('This is a search box. Click, write your query, and press enter to find')+'"'+
    ' title="'+_('Click, write and press enter to find')+'">'+
    '<input name="query" value="'+s+'"'+
    ' onfocus="if(this.value==\''+s+'\'){this.value=\'\'} this.form.className=\'focus-in\'"'+
    ' onblur="if(/^\s*$/.test(this.value)){this.value=\''+s+'\'} this.form.className=\'focus-out\'">'+
    '</form>'
  end

  def theme_opt_menu_search
    opt = theme_option( :menu_search )
    if    opt == 'none'
      ""
    elsif opt == 'simple_search'
      theme_simple_search_menu_search
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

  def file_field_or_thumbnail(label, image, for_attr, type = 'default', removable = true)
    display_form_field label, (
      render :partial => (image && image.valid? ? 'shared/show_thumbnail' : 'shared/change_image'),
      :locals => { :image => image, :removable => removable, :for_attr => for_attr, :type => type }
      )
  end

  def rolename_for(profile, resource)
    roles = profile.role_assignments.
      where(:resource_id => resource.id).
      sort_by{ |role_assignment| role_assignment.role_id }.
      map(&:role)
    names = []
    roles.each do |role|
      names << content_tag('span', role.name, :style => "color: #{role_color(role, resource.environment.id)}").html_safe
    end
    safe_join(names, ', ')
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

    (field_helpers - %i(hidden_field)).each do |selector|
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
      html = html.html_safe
      html += "<br />\n".html_safe if line_size == 0 || ( values.size % line_size ) > 0
      column = object.class.columns_hash[method.to_s] if object
      text =
        ( column ?
          column.human_name :
          _(method.to_s.humanize)
        )
      label_html = self.class.content_tag 'label', text,
                                        :class => 'formlabel'
      control_html = self.class.content_tag 'div', html.html_safe,
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
  # that the first occurrence of id=['"]([^'"]*)['"] in +field_html+ if the one
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
      field_html ||= ''.html_safe
      field_html   = [field_html, capture(&block)].safe_join
    end

    if is_required
      field_html = required(field_html)
    end

    if controller.action_name == 'signup' || controller.action_name == 'new_community' || (controller.controller_name == "enterprise_registration" && controller.action_name == 'index') || (controller.controller_name == 'home' && controller.action_name == 'index' && user.nil?)
      if profile.signup_fields.include?(name)
        result = field_html
      end
    else
      if profile.active_fields.include?(name)
        result = content_tag :div, class: 'field-with-privacy-selector' do
          [field_html, profile_field_privacy_selector(profile, name)].safe_join
        end
      end
    end

    result
  end

  def profile_field_privacy_selector(profile, name)
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

  class View < ActionView::Base
    def url_for *args
      self.controller.url_for *args
    end
  end

  def helper_for_article(article)
    article_helper = View.new
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

  def display_short_format(article, options={})
    options[:comments_link] ||= true
    options[:read_more_link] ||= true
    lead_links = (options[:comments_link] ? link_to_comments(article) : '') + (options[:read_more_link] ? reference_to_article( _('Read more'), article) : '')
    html = content_tag('div',
             article.lead +
             content_tag('div',
               lead_links.html_safe,
               :class => 'read-more'
             ),
             :class => 'short-post'
           )
    html.html_safe
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
    number_to_currency(value,  :format => "%u %n", locale: currency_locale())
  end

  def currency_locale
    current_lang = environment.default_language
    return :"pt-BR" if current_lang.eql? 'pt'
    current_lang.try(:to_sym)
  end

  def currency_symbol
    current_lang = environment.default_language
    return "R$" if current_lang.eql? 'pt'
    return "€" if (current_lang.eql? 'fr' or current_lang.eql? 'es')
    "$"
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


  def sort_categories(categories)
    categories = categories.sort{|x,y| x.name <=> y.name}
    return categories
  end

  def display_category_item(block, categories, root = true)
    categories.map do |category|
      category_path = { :controller => 'search', :action => 'category_index', :category_path => category.explode_path }
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
  end


  def display_category_menu(block, categories, root = true)
    categories = sort_categories(categories)
    return "" if categories.blank?
    content_tag(:ul) do
        display_category_item(block,categories)
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
    host = environment.default_hostname
    links = {
      s_('contents|More recent') => {href: url_for({host: host, controller: 'search', action: 'contents', filter: 'more_recent'})},
      s_('contents|More viewed') => {href: url_for({host: host, controller: 'search', action: 'contents', filter: 'more_popular'})},
      s_('contents|Most commented') => {href: url_for({host: host, controller: 'search', action: 'contents', filter: 'more_comments'})}
    }
    if logged_in?
      links.merge(_('New content') => modal_options({:href => url_for({:controller => 'cms', :action => 'new', :profile => current_user.login, :cms => true})}))
    end

    link_to(font_awesome(:article, _('Contents')), { controller: "search", action: 'contents', category_path: nil }, { id: 'submenu-contents', class: 'icon-menu-articles' })
  end
  alias :browse_contents_menu :search_contents_menu

  def search_people_menu
    return '' if user && !user.environment.enabled?(:search_people)
    link_to(font_awesome(:user, _('People')), { controller: "search", action: 'people', category_path: ''}, { id: 'submenu-people', class: 'icon-menu-people' })
  end
  alias :browse_people_menu :search_people_menu

  def search_people_options
    host = environment.default_hostname
    [
      (link_to s_('people|More recent'), controller: 'search', action: 'people', order: 'more_recent'),
      (link_to s_('people|More active'), controller: 'search', action: 'people', order: 'more_active'),
      (link_to s_('people|More popular'), controller: 'search', action: 'people', order: 'more_popular')
    ]
  end

  def search_community_options
    host = environment.default_hostname
    [
      (link_to s_('communities|More recent'), controller: 'search', action: 'communities', order: 'more_recent'),
      (link_to s_('communities|More active'), controller: 'search', action: 'communities', order: 'more_active'),
      (link_to s_('communities|More popular'), controller: 'search', action: 'communities', order: 'more_popular')
    ]
  end

  def search_communities_menu
    return '' if user && !user.environment.enabled?(:search_communities)
    link_to(font_awesome(:users, _('Communities')), { controller: "search", action: 'communities' }, { id: 'submenu-communities', class: 'icon-menu-community' })
  end
  alias :browse_communities_menu :search_communities_menu

  def search_events_menu
    @search_events_url = content_tag(:a, content_tag(:i, "", :class => 'fa fa-calendar') + _('Events'), :class => 'icon-menu-events', :href => "/search/events", :id => 'submenu-events')
    render :text => @search_events_url
  end
  alias :browse_events_menu :search_events_menu

  def pagination_links(collection, options={})
    options = { previous_label: content_tag(:span, font_awesome(:back, _('Previous'))),
                next_label:     content_tag(:span, "#{_('Next')} #{font_awesome(:next)}".html_safe),
                inner_window: 1,
                outer_window: 0,
                params: @filters }.merge(options)
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
    result.html_safe
  end

  def manage_link(list, kind, title, icon = '')
    if list.present?
      link_to_all = nil
      if list.count > 5
        list = list.first(5)
        link_to_all = link_to( font_awesome(:see_more, _('See all')), :controller => 'memberships', :profile => user.identifier)
      end
      link = list.map do |element|
        link_to( font_awesome( icon, _('Manage %s').html_safe % element.short_name(25)),
                 element.admin_url, :title => (_('Manage %s').html_safe % element.short_name))
      end
      if link_to_all
        link << link_to_all
      end
      render :partial => "shared/manage_link", :locals => {:link => link, :kind => kind.to_s, :title => font_awesome(icon, title)}
    end
  end

  def manage_enterprises
    return '' unless user && user.environment.enabled?(:display_my_enterprises_on_user_menu)
    manage_link(user.enterprises, :enterprises, _('My enterprises'), :enterprise).to_s
  end

  def manage_communities
    return '' unless user && user.environment.enabled?(:display_my_communities_on_user_menu)
    administered_communities = user.communities.more_popular.select {|c| c.admins.include? user}
    manage_link(administered_communities, :communities, _('My communities'), :users).to_s
  end

  def admin_link
    admin_icon = font_awesome(:admin, _('Administration'))
    user.is_admin?(environment) ? link_to(admin_icon, environment.admin_url, title: _("Configure the environment"), class: 'admin-link') : nil
  end

  def usermenu_logged_in
    pending_tasks_count = ''
    count = user ? Task.to(user).pending.count : -1

    if count > 0
      pending_tasks_count = link_to(count.to_s,
      user.tasks_url,
      :id => 'pending-tasks-count',
      :title => _("Manage your pending tasks"))
    end

    join_result = safe_join(user_menu_items(pending_tasks_count), "")
    join_result
  end

  def main_dropdown_items
    [
      search_contents_menu,
      search_people_menu,
      search_communities_menu,
      search_events_menu
    ]
  end


  def user_menu_items
    [
      search_contents_menu,
      search_people_menu,
      search_events_menu,
      search_communities_menu,
      render_environment_features(:usermenu).html_safe,
      user.is_admin?(environment) ? admin_link : nil,
      manage_enterprises,
      manage_communities,
      ctrl_panel_link,
      *plugins_items,
      logout_link,
      angular_logout_script
    ]
  end

  def angular_logout_script
    javascript_include_tag('clear-localstorage.js')
  end

  def logout_link
    link_to(font_awesome(:logout, _('Logout')), { controller: 'account', action: 'logout' }, id: "logout", title: _("Leave the system"))
  end

  def plugins_items
    actions = []
    plugins_toolbar(user).each do |item|
      item[:html_options] ||= {}
      item[:html_options][:title] ||= item[:title]
      title = font_awesome(item[:icon], item[:title])
      actions << link_to( title, item[:url], item[:html_options])
    end
    actions
  end

  def welcome_span
    user_identifier = "<i style='background-image:url(#{user.profile_custom_icon(gravatar_default)})'></i><strong>#{user.identifier}</strong>"
    welcome_link = link_to(user_identifier.html_safe,
        user.url,
        :id => "homepage-link",
        :title => _('Go to your homepage'))
    welcome_link.html_safe
  end

  def ctrl_panel_link
    link_to(font_awesome(:control_panel, _('Control panel')), user.admin_url,
                          class: 'ctrl-panel', title: _("Configure your personal account and content"))
  end

  def modal_link_to_login
    modal_inline_link_to(font_awesome(:login, _('Login')), '#', '#inlineLoginBox', id: 'link_login')
  end

  def link_to_signup
    link_to(font_awesome(:user, _('Sign up')), controller: 'account', action: 'signup')
  end

  def limited_text_area(object_name, method, limit, text_area_id, options = {})
    content_tag(:div, safe_join([
      text_area(object_name, method, { :id => text_area_id, :onkeyup => "limited_text_area('#{text_area_id}', #{limit})" }.merge(options)),
      content_tag(:p, content_tag(:span, limit) + ' ' + _(' characters left'), :id => text_area_id + '_left'),
      content_tag(:p, _('Limit of characters reached'), :id => text_area_id + '_limit', :style => 'display: none')
    ]), :class => 'limited-text-area')
  end

  def expandable_text_area(object_name, method, text_area_id, options = {})
    options[:class] = (options[:class] || '') +  ' autogrow'
    text_area(object_name, method, { :id => text_area_id }.merge(options))
  end

  def pluralize_without_count(count, singular, plural = nil)
    count == 1 ? singular : (plural || singular.pluralize)
  end

  def unique_with_count(list, connector = 'for')
    list.sort.inject(Hash.new(0)){|h,i| h[i] += 1; h }.collect{ |x, n| [n, connector, x].join(" ") }.sort
  end

  def comment_balloon(options = {}, &block)
    wrapper = content_tag(:div, capture(&block), :class => 'comment-balloon-content')
    classes = options.delete(:class) || options.delete("class") || ''
    concat(content_tag('div', wrapper + tag('br', :style => 'clear: both;'), { :class => 'comment-balloon ' + classes.to_s }.merge(options)))
  end

  def display_source_info(page)
    if !page.source.blank?
      source_url = link_to(page.source_name.blank? ? page.source : page.source_name, page.source)
    elsif page.reference_article
      source_url = link_to(page.reference_article.profile.name, page.reference_article.url)
    end
    content_tag(:div, _('Source: %s').html_safe % source_url.html_safe, :id => 'article-source') unless source_url.nil?
  end


  def task_target_url(task, values, params = {})
    values.merge!({:target => link_to(task.target.name, task.target.url)})
    target_detail = _("in %s").html_safe % values[:target]
    target_detail = '' if task.target.identifier == params[:profile]
    values.merge!({:target_detail => target_detail})
    return values
  end

  def task_information(task, params = {})
    values = {}
    values.merge!(task.information[:variables]) if task.information[:variables]
    values.merge!({:requestor => link_to(task.requestor.name, task.requestor.url)}) if task.requestor
    if (task.target && task.target.respond_to?(:url))
      values =  task_target_url(task, values, params)
    end
    values.merge!({:subject => content_tag('span', task.subject, :class=>'task_target')}) if task.subject
    values.merge!({:linked_subject => link_to(content_tag('span', task.linked_subject[:text], :class => 'task_target'), task.linked_subject[:url])}) if task.linked_subject
    (task.information[:message] % values).html_safe
  end

  def add_zoom_to_article_images
    add_zoom_to_images if environment.enabled?(:show_zoom_button_on_article_images)
  end

  def add_zoom_to_images
    stylesheet_link_tag('vendor/jquery.fancybox') +
    javascript_include_tag('vendor/jquery.fancybox.pack') +
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
    text = font_awesome(:alert, _('Report abuse'))
    klass = 'report-abuse-action '
    already_reported_message = _('You already reported this profile.')
    report_profile_message = _('Report this profile for abusive behaviour')
    report_depending_component(profile, type, content, url, text, klass, already_reported_message, report_profile_message)
  end

  def report_depending_component(profile, type, content, url, text, klass, already_reported_message, report_profile_message)
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
        link_to(text, url, :class => klass + 'with-text icon-alert', :title => report_profile_message)
      end
    elsif type == :comment_link
      user.already_reported?(profile) ?
        content_tag('a', text, :class => klass + 'disabled', :title => already_reported_message) :
        link_to(text, url, :class => klass, :title => report_profile_message)
    end
  end

  def cache_timeout(key, timeout, &block)
    cache(key, { :expires_in => timeout, :skip_digest => true }, &block)
  end

  def is_cache_expired?(key)
    !cache_store.fetch(ActiveSupport::Cache.expand_cache_key(key, :controller))
  end

  def render_tabs(tabs)
    titles = tabs.inject(''.html_safe){ |result, tab| result << content_tag(:li, link_to(tab[:title], '#'+tab[:id]), :class => 'tab') }
    contents = tabs.inject(''.html_safe){ |result, tab| result << content_tag(:div, tab[:content], :id => tab[:id]) }

    content_tag(:div, content_tag(:ul, titles) + raw(contents), :class => 'ui-tabs')
  end

  def delete_article_message(article)
    if article.folder?
      _("Are you sure that you want to remove the folder \"%s\"? Note that all the items inside it will also be removed!") % article.title
    else
      _("Are you sure that you want to remove the item \"%s\"?") % article.title
    end
  end

  def expirable_link_to(expired, content, url, options = {})
    if expired
      options[:class] = (options[:class] || '') + ' disabled'
      content_tag('a', content, options)
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
    content.folder? || (profile == user && user.communities.blank? && !environment.portal_enabled)
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

  def define_template_radio_buttons(templates, field_name)
    radios = templates.map do |template|
      content_tag('li', labelled_radio_button(link_to(template.name, template.url, :target => '_blank'), "#{field_name}[template_id]", template.id, environment.is_default_template?(template)))
    end.join("\n").html_safe
    return radios
  end

  def template_options(kind, field_name)
    templates = environment.send(kind).templates
    return '' if templates.count == 0
    return hidden_field_tag("#{field_name}[template_id]", templates.first.id) if templates.count == 1

    radios = define_template_radio_buttons(templates, field_name)

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
        safe_join(errors.map { |err| content_tag(:li, err.html_safe) })
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
    default_folder = profile.folders.find_by type: 'Gallery'
    default_folder = profile.folders.find_by type: 'Folder' if default_folder.nil?
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
    profiles << link_to("<big> +#{suggestion.profile_connections.count - 4}</big>".html_safe, :controller => controller_target, :action => :connections, :id => suggestion.suggestion_id) if suggestion.profile_connections.count > 4

    if profiles.present?
      content_tag(:div, profiles.safe_join , :class => 'profile-connections')
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

  def toggle_switch name, message, value = 1, checked = false
    checkbox = check_box_tag(name, value, checked)
    toggle = content_tag(:span, '',:class => 'toggle-slider')
    label = label_tag(name, checkbox + toggle, :id => name + '-label')
    message = content_tag(:span, message)
    content_tag(:div, label + message, :class => 'toggle-switch')
  end

  def labelled_colorpicker_field(human_name, object_name, method, options = {})
    options[:id] ||= 'text-field-' + FormsHelper.next_id_number
    content_tag('label', human_name, :for => options[:id], :class => 'formlabel') +
    colorpicker_field(object_name, method, options.merge(:class => 'colorpicker_field'))
  end

  def colorpicker_field(object_name, method, options = {})
    text_field(object_name, method, options.merge(:class => 'colorpicker_field'))
  end

  def fullscreen_buttons(item_id)
    content =  javascript_tag "fullscreenPageLoad('#{item_id}')"
    content += content_tag('a', font_awesome(:fullscreen, _("Full screen")), { id: "fullscreen-btn",
                                                    onclick: "toggle_fullwidth('#{item_id}')",
                                                    href: "#",
                                                    title: _("Go to full screen mode") })

    content += content_tag('a', font_awesome(:fullscreen_out, _("Exit full screen")), { id: "exit-fullscreen-btn",
                                                         onclick: "toggle_fullwidth('#{item_id}')",
                                                         href: "#",
                                                         title: _("Exit full screen mode"),
                                                         style: "display: none;" })
    content.html_safe
  end

  def current_editor_is?(editor)
    editor.blank? ? false : current_editor == editor
  end

  def current_editor(mode = '')
    editor = @article.editor || Article::Editor::TINY_MCE unless @article.nil?
    editor ||= (current_person.nil? || current_person.editor.nil?) ? Article::Editor::TINY_MCE : current_person.editor
    editor += '_' + mode unless mode.blank?
    editor
  end

  def captcha_tags(action, user, environment, profile = nil)
    if environment.require_captcha?(action, user, profile)
      content_tag('div', recaptcha_tags(:ajax => true, :script => true),
                  class: 'recaptcha-wrapper')
    end
  end
end
