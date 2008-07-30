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
    profile ||= current_user.login
    link_to text, homepage_path(:profile => profile) , options
  end

  def link_to_myprofile(text, url = {}, profile = nil, options = {})
    profile ||= current_user.login
    link_to text, { :profile => profile, :controller => 'profile_editor' }.merge(url), options
  end

  def link_to_document(doc, text = nil)
    text ||= doc.title
    path = doc.path.split(/\//)
    link_to text, homepage_path(:profile => doc.profile.identifier , :page => path)
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
    @controller.send(:profile) || raise("There is no current profile")
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

  def file_manager(&block)
    concat(
      content_tag('div',
        content_tag('div', capture(&block) + '<br style="clear:left;"/>&nbsp;'),
        :class => 'file-manager'),
      block.binding)
  end

  def file_manager_button(title, icon, url)
    content_tag('div', link_to(image_tag(icon, :alt => title, :title => title) + content_tag('div', title), url), :class => 'file-manager-button')
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
    link_to(content_tag('span', label), url, html_options.merge(:class => the_class ))
  end

  def button_to_function(type, label, js_code, html_options = {})
    html_options[:class] = "button with-text" unless html_options[:class]
    html_options[:class] << " icon-#{type}"
    link_to_function(label, js_code, html_options)
  end

  def button_to_function(type, label, js_code, html_options = {}, &block)
    html_options[:class] = "button with-text" unless html_options[:class]
    html_options[:class] << " icon-#{type}"
    link_to_function(label, js_code, html_options, &block)
  end

  def button_to_function_without_text(type, label, js_code, html_options = {})
    html_options[:class] = "" unless html_options[:class]
    html_options[:class] << " button icon-#{type}"
    link_to_function(content_tag('span', label), js_code, html_options)
  end

  def button_to_function_without_text(type, label, js_code, html_options = {}, &block)
    html_options[:class] = "" unless html_options[:class]
    html_options[:class] << " button icon-#{type}"
    link_to_function(content_tag('span', label), js_code, html_options, &block)
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

  def link_to_category(category, full = true)
    return _('Uncategorized product') unless category
    name = full ? category.full_name(' &rarr; ') : category.name
    link_to name, :controller => 'search', :action => 'category_index', :category_path => category.path.split('/')
  end

  def link_to_product(product, opts={})
    return _('No product') unless product
    link_to content_tag( 'span', product.name ),
            { :controller => 'catalog', :action => 'show', :id => product, :profile => product.enterprise.identifier },
            opts
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
      result << '/designs/themes/' + current_theme
    end
    result << '/stylesheets/' << name << '.css'
  end

  # FIXME do not hardcode 'default' like this
  def current_theme
    'default'
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
    if profile.class == Person
      sex = ( profile.sex ? profile.sex.to_s() : 'undef' )
      title = ( sex == 'undef' ? _('non registered gender') : ( sex == 'male' ? _('Male') : _('Female') ) )
      sex = content_tag 'span',
                        content_tag( 'span', sex ),
                        :class => 'sex-'+sex,
                        :title => title
    else
      sex = ''
    end
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
            :class => 'profile_link url',
            :help => _('Click on this icon to go to the <b>%s</b>\'s home page') % profile.name ),
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

  def theme_option(opt = nil)
    conf = RAILS_ROOT.to_s() +
           '/public/designs/themes/' +
           current_theme.to_s() +
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
      file = '/designs/themes/'+ current_theme.to_s() +
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
    content_tag('span', role.name, :style => "color: #{role_color(role)}")
  end

  def role_color(role)
    case role
      when Profile::Roles.admin
        'blue'
      when Profile::Roles.member
        'green'
      when Profile::Roles.moderator
        'gray'
      else
        'black'
    end
  end

  def txt2html(txt)
    txt.
      gsub( /\n\s*\n/, ' <p/> ' ).
      gsub( /\n/, ' <br/> ' ).
      gsub( /(^|\s)(www\.[^\s])/, '\1http://\2' ).
      gsub( /(https?:\/\/([^\s]+))/,
            '<a href="\1" target="_blank" rel="nofolow" onclick="return confirm(\'' +
            escape_javascript( _('Are you sure you want to visit this web site?') ) +
            '\n\n\'+this.href)">\2</a>' )
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

  def search_page_title(title, options={})
    title = "<h1>" + title + "</h1>"
    title += "<h2 align='center'>" + _("Searched for '%s'") % options[:query] + "</h2>" if !options[:query].blank?
    title += "<h2 align='center'>" + _("In category %s") % options[:category] + "</h2>" if !options[:category].blank?
    title += "<h2 align='center'>" + _("within %d km from %s") % [options[:distance], options[:region]] + "</h2>" if !options[:distance].blank? && !options[:region].blank?
    title += "<h2 align='center'>" + _("%d results found") % options[:total_results] + "</h2>" if !options[:total_results].blank?
    title
  end

end
