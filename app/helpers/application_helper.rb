# Methods added to this helper will be available to all templates in the
# application.
module ApplicationHelper

  include PermissionName

  include LightboxHelper

  include BoxesHelper

  include FormsHelper
  
  include AssetsHelper

  include BlockHelper
  
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

  def labelled_form_for(name, object = nil, options = {}, &proc)
    object ||= instance_variable_get("@#{name}")
    form_for(name, object, { :builder => NoosferoFormBuilder }.merge(options), &proc)
  end

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

      label_html = content_tag('label', text, :class => 'formlabel', :for => field_id)
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
              _(field.to_s.humanize)
            )

          NoosferoFormBuilder::output_field(text, super)
        end
      END_SRC
      class_eval src, __FILE__, __LINE__
    end
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
    concat(content_tag('div', capture(&block), :class => 'file-manager') + "<br style='clear: left;'/>", block.binding)
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
  alias icon_button button_without_text

  def submit_button(type, label, html_options = {})
    bt_cancel = html_options[:cancel] ? button(:cancel, _('Cancel'), html_options[:cancel]) : ''

    html_options[:class] = [html_options[:class], 'submit'].compact.join(' ')
    
    the_class = "button with-text icon-#{type}"
    if html_options.has_key?(:class)
      the_class << ' ' << html_options[:class]
    end

    bt_submit = submit_tag(label, html_options.merge(:class => the_class))

    bt_submit
  end

  def button_to_function(type, label, js_code, html_options = {})
    html_options[:class] = "" unless html_options[:class]
    html_options[:class] << " button #{type}"
    link_to_function(label, js_code, html_options)
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
    name = full ? category.full_name : category.name
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
          '/images/icons-app/gnome-home_size-'+ size.to_s() +'.png'
        end
      else
        '/images/icons-app/user_icon_size-'+ size.to_s() +'.png'
      end
    end

  end

  # displays a link to the profile homepage with its image (as generated by
  # #profile_image) and its name below it.
  def profile_image_link(profile, size=:portrait)
    link_to( '<div>'+ profile_image(profile, size) +'</div><span>'+ profile.name() +'</span>', profile.url,
             :help => _('Click on this icon to go to the <b>%s</b>\'s home page') % profile.name )
  end

  def text_field_with_local_autocomplete(name, choices, html_options = {})
    id = html_options[:id] || name

    text_field_tag(name, '', html_options) +
    content_tag('div', '', :id => "autocomplete-for-#{id}", :class => 'auto-complete', :style => 'display: none;') +
    javascript_tag('new Autocompleter.Local(%s, %s, %s)' % [ id.to_json, "autocomplete-for-#{id}".to_json, choices.to_json ] )

  end

  # formats a date for displaying.
  def show_date(date)
    if date
      date.strftime(_('%d %B %Y'))
    else
      ''
    end
  end

  # formats a datetime for displaying. 
  def show_time(time)
    if time
      time.strftime(_('%d %B %Y, %H:%m'))
    else
      ''
    end
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
  def select_categories(object_name)
    object = instance_variable_get("@#{object_name}")

    result = content_tag('h4', _('Categories'))
    environment.top_level_categories.each do |toplevel|
      toplevel.map_traversal do |cat|
        if cat.top_level?
          result << content_tag('h5', toplevel.name)
        else
          checkbox_id = "#{object_name}_#{cat.full_name.downcase.gsub(/\s+|\//, '_')}"
          result << content_tag('label', check_box_tag("#{object_name}[category_ids][]", cat.id, object.category_ids.include?(cat.id), :id => checkbox_id) + cat.full_name_without_leading(1), :for => checkbox_id)
        end
      end
    end

    content_tag('div', result)
  end

  def select_city(name, top_level='Nacional')
    city_field_name = "#{object}[#{method}]"
    state_field_name = "#{object}_#{method}_state"
    region_field_name = "#{object}_#{method}_region"

    selected_state = nil
    selected_region = nil

    regions = Region.find_by_name(top_level).children

    select_tag(region_field_name, options_for_select(regions.map {|r| [r.name, r.id] } + ['---','']) +
    select_tag(state_field_name, options_for_select(['---', ''])) + 
    select_tag(city_fied_name, options_for_select(['---',''])) +

    observe_field(country_field_name, :update => state_field_name, :url => { :controller => 'geography', :action => 'states' }, :with => 'country' ) +
    observe_field(country_field_name, :update => city_field_name, :url => { :controller => 'geography', :action => 'cities_by_country' }, :with => 'country') +
    observe_field(state_field_name, :update => city_field_name, :url => { :controller => 'geography', :action => 'cities' }, :with => 'state_id')
  end

end
