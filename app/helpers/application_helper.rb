# Methods added to this helper will be available to all templates in the
# application.
module ApplicationHelper
  include PermissionName
  
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
  def help(content = nil, type = :html, &block)

    @help_message_id ||= 1
    help_id = "help_message_#{@help_message_id}"

    if content.nil?
      return '' if block.nil?
      content = capture(&block)
    end

    if type == :textile
      content = RedCloth.new(content).to_html
    end

    # TODO: implement this button, and add style='display: none' to the help
    # message DIV
    button = link_to_function(content_tag('span', _('Help')), "Element.show('#{help_id}')", :class => 'help_button' )
    close_button = content_tag("div", link_to_function(_("Close"), "Element.hide('#{help_id}')", :class => 'close_help_button'))

    text = content_tag('div', button + content_tag('div', content_tag('div', content) + close_button, :class => 'help_message', :id => help_id, :style => 'display: none;'), :class => 'help_box')

    unless block.nil?
      concat(text, block.binding)
    end

    text
  end

  # alias for <tt>help(content, :textile)</tt>. You can pass a block in the
  # same way you would do if you called <tt>help</tt> directly.
  def help_textile(content = nil, &block)
    help(content, :textile, &block)
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
    link_to text, { :profile => profile }.merge(url), options
  end

  def link_to_document(doc, text = nil)
    text ||= doc.title
    path = doc.full_path.split(/\//)
    profile = path.shift
    link_to text, homepage_path(:profile => profile , :page => path)
  end

  # TODO: add the actual links
  # TODO: test this helper
  def user_links
    links = [
       ( link_to_homepage( _('My account') )),
       ( link_to_myprofile _('My Enterprises'), {:controller => 'membership_editor'} ),
       ( link_to(_('Admin'), { :controller => 'admin_panel' }) if current_user.person.is_admin?),
       ( link_to_document (about_document), _('About')  if about_document ),
    ].join("\n")
    content_tag('span', links, :id => 'user_links')
  end

  def about_document
    Article.find_all_by_slug(_('about')).select do |a| 
      a.full_path.split(/\//).shift == 'noosfero'
    end[0]
  end

  def shortcut_header_links
    if logged_in?
      [ accessibility_link, 
        ( link_to_homepage( content_tag('span', _('My account')),nil, { :id => 'icon_go_home'} ) ), 
	# MUDAR, O ID acima deve ser no Link <a id=...
	# O ID icon_accessibility tambem tem que aparcer e testei o link nao ta funcionado.
        ( link_to content_tag('span', _('Admin')), { :controller => 'admin_panel' }, :id => 'icon_admin' if current_user.person.is_admin?), 
        ( link_to content_tag('span', _('Logout')), { :controller => 'account', :action => 'logout', :method => 'post'}, :id => 'icon_logout'),
      ]
    else
      [ accessibility_link,
        ( link_to content_tag('span', _('Login')), { :controller => 'account', :action => 'login' }, :id => 'icon_login' ),
      ]
    end.join(" ")
  end

  def header
    login_or_register_or_logout
  end

  def login_or_register_or_logout
    if logged_in?
      user_links + " " + logout_box
    else
      login_box + " " + register_box
    end
  end

  def login_box
    content_tag('span', (link_to _('Login'), :controller => 'account', :action => 'login'), :id => 'login_box')
  end

  def register_box
    content_tag('span', (link_to _('Not a user yet? Register now!'), :controller => 'account', :action => 'signup'), :id => 'register_box')
  end

  def logout_box
    content_tag('span', (link_to _('Logout'), { :controller => 'account', :action => 'logout'}, :method => 'post'), :id => 'logout_box')
  end

  def link_if_permitted(link, permission = nil, target = nil)
    if permission.nil? || current_user.person.has_permission?(permission, target)
      link
    else
      nil
    end
  end

  def admin_links
    environment = current_user.person.environment
    links = [
      [(link_to _('Features'), :controller => 'features'), 'edit_environment_features', environment],
      [(link_to _('Edit visual'), :controller => 'edit_template'), 'edit_environment_design', environment],
      [(link_to _('Manage categories'), :controller => 'categories'), 'manage_environment_categories', environment],
      [(link_to _('Manage permissions'), :controller => 'role'), 'manage_environment_roles', environment],
      [(link_to _('Manage validators'), :controller => 'region_validators'), 'manage_environment_validators', environment],
    ]
  end

  def membership_links
    links = [
      [(link_to _('New enterprise'), :controller => 'membership_editor', :action => 'new_enterprise'),'create_enterprise_for_profile', profile],
    ]
  end
  
  def person_links
    links = [
      [(link_to_myprofile _('Edit visual design'), {:controller => 'profile_editor', :action => 'design_editor'}, profile.identifier), 'edit_profile_design', profile],
      [(link_to_myprofile _('Edit profile'), {:controller => 'profile_editor'}, profile.identifier), 'edit_profile', profile],
      [(link_to_myprofile _('Manage content'), {:controller => 'cms'}, profile.identifier), 'post_content', profile],
    ]
  end

  
  def enterprise_links
    links = [
      [(link_to_myprofile _('Edit visual design'), {:controller => 'profile_editor', :action => 'design_editor'}, profile.identifier), 'edit_profile_design', profile],
      [(link_to_myprofile _('Edit informations'), {:controller => 'profile_editor'}, profile.identifier), 'edit_profile', profile],
      [(link_to_myprofile _('Manage content'), {:controller => 'cms'}, profile.identifier), 'post_content', profile],
#      [(link_to_myprofile _('Exclude'), {:controller => 'enterprise_editor', :action => 'destroy'}, profile.identifier), 'edit_profile', profile],
    ]
  end

  def myprofile_links
    links = [
      [(link_to _('Change password'), {:controller => 'account', :action => 'change_password'}), 'edit_profile', profile]
    ]
  end

  def about_links
    links = [
      [(link_to _('Report bug'), 'http://www.colivre.coop.br/Noosfero/BugItem')],
    ]
  end

  def design_links
    links = [
      [(link_to _('Change template'), :controller => 'profile_editor', :action => 'design_editor_change_template')],
      [(link_to _('Change block theme'), :controller => 'profile_editor', :action => 'design_editor_change_theme')],
      [(link_to _('Change icon theme'), :controller => 'profile_editor', :action => 'design_editor_change_icon_theme')],
    ]
  end

  #FIXME: about_links should be shown even if the user isn't logged in
  def user_options
    return [] unless logged_in?
    profile = Profile.find_by_identifier(params[:profile])
    case params[:controller]
      when 'admin_panel'
        admin_links
      when 'membership_editor'
        membership_links
      when 'profile_editor'
        if profile.kind_of?(Enterprise) && params[:action] == 'index'
          enterprise_links
        elsif profile.kind_of?(Person) && params[:action] == 'index'
           myprofile_links
        elsif params[:action] == 'design_editor'
          design_links
        else
          []
        end
      when 'content_viewer'
        if params[:profile] == 'noosfero' && params[:page][0] == 'about'
          about_links
        else
          person_links
        end
      else
        []
    end.map{|l| link_if_permitted(l[0], l[1], l[2]) }
  end

#  def user_options
#  end

  def accessibility_link
    doc = Article.find_all_by_slug(_('accessibility')).select do |a| 
      a.full_path.split(/\//).shift == 'noosfero'
    end[0]
    link_to_document doc, _('Accessibility'), :id => 'icon_accessibility' if doc 
  end

  def search_box
    [form_tag( :controller => 'search', :action => 'index'),
      submit_tag(_('Search'), :id => 'button_search'),
      text_field_tag( 'query', _('  '), :id => "input_search"),
       '</form>',
      observe_field('input_search', :function => "element.value=''", :on => :focus)
    ].join("\n") 
  end

  def footer
    # FIXME: add some information from the environment
    [
      content_tag('div', 'Copyright © 2007, Noosfero - Change Me!'),
      content_tag('div', _('%s, version %s' % [ link_to('developers', 'http://www.colivre.coop.br/Noosfero'), Noosfero::VERSION])),
    ].join("\n")
  end

  # returns the current profile beign viewed.
  #
  # Make sure that you use this helper method only in contexts where there
  # should be a current profile (i.e. while viewing some profile's pages, or the
  # profile info, etc), because if there is no profile an exception is thrown.
  def profile
    @profile || raise("There is no current profile")
  end

  # displays an 
  #
  # Current implementation generates a <label> tag for +label+ and wrap the
  # label and the control with a <div> tag with class 'formfield' 
  def display_form_field(label, html_for_field)
    content_tag('div', content_tag('div', content_tag('label', label)) +html_for_field, :class => 'formfield') 
  end

  alias_method :labelled_form_field, :display_form_field

  def labelled_form_for(name, object = nil, options = {}, &proc)
    object ||= instance_variable_get("@#{name}")
    form_for(name, object, { :builder => NoosferoFormBuilder }.merge(options), &proc)
  end

  class NoosferoFormBuilder < ActionView::Helpers::FormBuilder
    include GetText

    (field_helpers - %w(hidden_field)).each do |selector|
      src = <<-END_SRC
        def #{selector}(field, *args, &proc)
          column = object.class.columns_hash[field.to_s]
          "<div class='formfieldline'>" +
          "\n  <label class='formlabel'" +
          " for='\#{object.class.to_s.downcase}_\#{field}'>" +
          ( column ?
            column.human_name :
            _(field.to_s.humanize)
          ) +
          "</label>" +
          "\n  <div class='formfield #{selector}'>" + super + "</div>\n</div>"
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
    filter_type = 
      if filter_type_method.blank?
        ''
      else
        instance_variable_get("@#{object}").send(filter_type_method)
      end
    if filter_type == '[No Filter]' || filter_type.blank?
      html_class = "tiny_mce_editor"
      if options[:class]
        html_class << " #{options[:class]}"
      end
      text_area(object, method, { :size => '72x12' }.merge(options).merge({:class => html_class})) 
    else
      text_area(object, method, { :size => '72x12' }.merge(options))
    end
  end

  def select_filter_type(object, method, html_options)
    options = [
      [ _('No Filter at all'), '[No Filter]' ],
      [ _('RDoc filter'), 'RDoc' ],
      [ _('Simple'), 'Simple' ],
      [ _('Textile'), 'Textile' ]
    ]
    select_tag "#{object}[#{method}]", options_for_select(options, @page.filter_type || Comatose.config.default_filter), { :id=> "#{object}_#{method}" }.merge(html_options)
  end
end
