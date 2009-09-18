# Methods added to this helper will be available to all templates in the
# application.
module ApplicationHelper

  include PermissionName

  include LightboxHelper

  include ThickboxHelper

  include BoxesHelper

  include FormsHelper
  
  include AssetsHelper

  include BlockHelper

  include DatesHelper

  include FolderHelper

  include ProfileEditorHelper

  include DisplayHelper

  include AccountHelper

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
      concat(text, block.binding)
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
    link_to('&nbsp;'+content_tag('span', label), url, html_options.merge(:class => the_class, :title => label))
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
    link_to_remote(content_tag('span', label), options, html_options)
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
    concat(content_tag('div', capture(&block) + tag('br', :style => 'clear: left;'), { :class => 'button-bar' }.merge(options)), block.binding)
  end

  def partial_for_class(klass)
    if klass.nil?
      raise ArgumentError, 'No partial for object. Is there a partial for any class in the inheritance hierarchy?'
    end
    
    name = klass.name.underscore
    if File.exists?(File.join(RAILS_ROOT, 'app', 'views', params[:controller], "_#{name}.rhtml"))
      name
    else
      partial_for_class(klass.superclass)
    end
  end

  def user
    @controller.send(:user)
  end

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

  def theme_stylesheet_path
    theme_path + '/style.css'
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
          else
            if profile
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
    file = (RAILS_ROOT + '/public' + theme_path + '/' + template  + '.rhtml')
    if File.exists?(file)
      render :file => file, :use_full_path => false
    end
  end

  def theme_header
    theme_include('header')
  end

  def theme_footer
    theme_include('footer')
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
    opt[:alt]   ||= profile.name()
    opt[:title] ||= ''
    opt[:class] ||= ''
    opt[:class] += ( profile.class == Person ? ' photo' : ' logo' )
    image_tag(profile_icon(profile, size), opt )
  end

  def profile_icon( profile, size=:portrait )
    if profile.image
      profile.image.public_filename( size )
    else
      if profile.organization?
        if profile.kind_of?(Community)
          '/images/icons-app/users_size-'+ size.to_s() +'.png'
        else
          '/images/icons-app/enterprise-default-pic-'+ size.to_s() +'.png'
        end
      else
        '/images/icons-app/user_icon_size-'+ size.to_s() +'.png'
      end
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
      icons =
        profile.product_categories.map{ |c| c.size > 1 ? c[1] : nil }.
          compact.uniq.map{ |c|
            cat_name = c.gsub( /[-_\s,.;'"]+/, '_' )
            cat_icon = "/images/icons-cat/#{cat_name}.png"
            if ! File.exists? RAILS_ROOT.to_s() + '/public/' + cat_icon
              cat_icon = '/images/icons-cat/undefined.png'
            end
            content_tag 'span',
                        content_tag( 'span', c ),
                        :title => c,
                        :class => 'product-cat-icon cat_icon_' + cat_name,
                        :style => "background-image:url(#{cat_icon})"
          }.join "\n"
      content_tag 'div',
                  content_tag( 'span', _('Principal Product Categories'), :class => 'header' ) +"\n"+ icons,
                  :class => 'product-category-icons'
    else
      ''
    end
  end

  # displays a link to add the profile with its image (as generated by
  # #profile_image) or only its name below.
  def profile_add_link( profile, image=false, size=:portrait, tag='li')
    the_class = profile.members.include?(user) ? 'profile_member' : ''
    name = profile.short_name
    if image
      display = content_tag( 'span', profile_image( profile, size ), :class => 'profile-image' ) +
                content_tag( 'span', name, :class => 'org' ) +
                profile_cat_icons( profile )
      the_class << ' vcard'
    else
      display = content_tag( 'span', name, :class => 'org' )
    end
    content_tag tag,
        link_to_remote( display,
	    :update => 'search-results-and-pages',
            :url => {:controller => 'account', :action => 'profile_details', :profile => profile.identifier},
            :onclick => 'document.location.href = this.href', # work-arround for ie.
            :class => 'profile_link url',
            :help => _('Click on this icon to add <b>%s</b> to your network') % profile.name,
            :title => profile.name ),
        :class => the_class
  end

  # displays a link to the profile homepage with its image (as generated by
  # #profile_image) and its name below it.
  def profile_image_link( profile, size=:portrait, tag='li' )
    if profile.class == Person
      name = profile.short_name
      city = content_tag 'span', content_tag( 'span', profile.city, :class => 'locality' ), :class => 'adr'
    else
      name = profile.short_name
      city = ''
    end
    content_tag tag,
        link_to(
            content_tag( 'span', profile_image( profile, size ), :class => 'profile-image' ) +
            content_tag( 'span', name, :class => ( profile.class == Person ? 'fn' : 'org' ) ) +
            city + profile_sex_icon( profile ) + profile_cat_icons( profile ),
            profile.url,
            :onclick => 'document.location.href = this.href', # work-arround for ie.
            :class => 'profile_link url',
            :help => _('Click on this icon to go to the <b>%s</b>\'s home page') % profile.name,
            :title => profile.name ),
        :class => 'vcard'
  end

  # displays a link to the community homepage with its image (as generated by
  # #profile_image) and its name and number of members beside it.
  def community_image_link( profile, size=:portrait, tag='li' )
    name = profile.name
    content_tag tag,
        link_to(
            content_tag( 'span', profile_image( profile, size ), :class => 'profile-image' ) +
            content_tag( 'span', name, :class => 'org' ) +
            content_tag( 'span', n_('1 member', '%s members', profile.members.count) % profile.members.count, :class => 'community-member-count' ),
            profile.url,
            :onclick => 'document.location.href = this.href', # work-arround for ie.
            :class => 'profile_link url',
            :help => _('Click on this icon to go to the <b>%s</b>\'s home page') % profile.name,
            :title => profile.name ) +
            '<br class="may-clear"/>',
        :class => 'vcard'
  end

  def gravatar_url_for(email, options = {})
    # Ta dando erro de roteamento
    url_for( { :gravatar_id => Digest::MD5.hexdigest(email),
               :host => 'www.gravatar.com',
               :protocol => 'http://',
               :only_path => false,
               :controller => 'avatar.php'
             }.merge(options) )
  end
    
  def str_gravatar_url_for(email, options = {})
    url = 'http://www.gravatar.com/avatar.php?gravatar_id=' +
           Digest::MD5.hexdigest(email)
    { :only_path => false }.merge(options).each { |k,v|
      url += ( '&%s=%s' % [ k,v ] )
    }
    # we can set the default imgage with this:
    # :default => 'DOMAIN/images/icons-app/gravatar-minor.gif'
    url
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
          result << '<div class="categorie_box">'
          result << icon_button( :down, _('open'), '#', :onclick => 'open_close_cat(this); return false' )
          result << content_tag('h5', toplevel.name)
          result << '<div style="display:none"><ul class="categories">'
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
      result << '</ul></div></div>'
    end

    content_tag('div', result)
  end

  def select_folder(label, object, method, collection, html_options = {}, js_options = {})
    labelled_form_field(label, select(object, method, collection.map {|f| [ profile.identifier + '/' + f.full_name, f.id ] }, html_options.merge({:include_blank => "#{profile.identifier}"}), js_options))
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
  include GetText
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
          column = object.class.columns_hash[field.to_s]
          text =
            ( column ?
              column.human_name :
              field.to_s.humanize
            )

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
          html += "<br />\n"
        end
      }
      html += "<br />\n"  if line_size == 0 || ( values.size % line_size ) > 0
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
    if (controller.action_name == 'signup')
      if profile.signup_fields.include?(name) || profile.required_fields.include?(name)
        result = field_html
      end
    else
      if profile.active_fields.include?(name)
        result = field_html
      end
    end
    if is_required
      result = required(result)
    end

    if block
      concat(result, block.binding)
    end

    result
  end

  def search_page_title(title, options={})
    title = "<h1>" + title + "</h1>"
    title += "<h2 class='query'>" + _("Searched for '%s'") % options[:query] + "</h2>" if !options[:query].blank?
    title += "<h2 class='query'>" + _("In category %s") % options[:category] + "</h2>" if !options[:category].blank?
    title += "<h2 class='query'>" + _("within %d km from %s") % [options[:distance], options[:region]] + "</h2>" if !options[:distance].blank? && !options[:region].blank?
    title += "<h2 class='query'>" + _("%d results found") % options[:total_results] + "</h2>" if !options[:total_results].blank?
    title
  end

  def search_page_link_to_all(options={})
    if options[:category]
      title = "<div align='center'>" + _('In all categories') + "</div>"
      link_to title, :action => 'assets', :asset => options[:asset], :category_path => []
    end
  end

  def template_stylesheet_path
    if profile.nil?
      '/designs/templates/default/stylesheets/style.css'
    else
      "/designs/templates/#{profile.layout_template}/stylesheets/style.css"
    end
  end
  def template_stylesheet_tag
    stylesheet_import template_stylesheet_path()
  end

  def login_url
    options = Noosfero.url_options.merge({ :controller => 'account', :action => 'login' })
    if environment.enable_ssl && (ENV['RAILS_ENV'] != 'development')
      options.merge!(:protocol => 'https://', :host => ssl_hostname)
    end
    url_for(options)
  end

  def ssl_hostname
    environment.default_hostname
  end

  def base_url
    environment.top_url(request.ssl?)
  end

  def helper_for_article(article)
    article_helper = ActionView::Base.new
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

  def meta_tags_for_article(article)
    if @controller.controller_name == 'content_viewer'
      if article and (article.blog? or (article.parent and article.parent.blog?))
        blog = article.blog? ? article : article.parent
        "<link rel='alternate' type='application/rss+xml' title='#{blog.feed.title}' href='#{url_for blog.feed.url}' />"
      end
    end
  end

  def ask_to_join?
    return if !environment.enabled?(:join_community_popup)
    return if params[:action] == 'join'
    return unless profile && profile.kind_of?(Community)
    if (session[:no_asking] && session[:no_asking].include?(profile.id))
      return false
    end
    if logged_in?
      user.ask_to_join?(profile)
    else
      true
    end
  end

  def icon_theme_stylesheet_path
    theme_path = "/designs/icons/#{environment.icon_theme}/style.css"
    if File.exists?(File.join(RAILS_ROOT, 'public', theme_path))
      theme_path
    else
      '/designs/icons/default/style.css'
    end
  end

  def icon_theme_stylesheet_tag
    theme_path = "/designs/icons/#{environment.icon_theme}/style.css"
    stylesheet_import icon_theme_stylesheet_path()
  end

  def page_title
    (@page ? @page.name + ' - ' : '') +
    (@profile ? @profile.name + ' - ' : '') +
    @environment.name +
    (@category ? "&rarr; #{@category.full_name}" : '')
  end

  def noosfero_javascript
    render :file =>  'layouts/_javascript'
  end

  def import_controller_stylesheets(options = {})
    stylesheet_import( "controller_"+ @controller.controller_name(), options )
  end

  def pngfix_stylesheet_path
    'iepngfix/iepngfix.css'
  end
  def pngfix_stylesheet
    stylesheet_import pngfix_stylesheet_path()
  end

  def noosfero_layout_features
    render :file => 'shared/noosfero_layout_features'
  end

  def link_to_email(email)
    javascript_tag('var array = ' + email.split('@').to_json + '; document.write("<a href=\'mailto:" + array.join("@") + "\'>" + array.join("@") +  "</a>")')
  end

end
