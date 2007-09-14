# Methods added to this helper will be available to all templates in the
# application.
module ApplicationHelper

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
  # Formally, the <tt>type</tt> argument can be <tt>:html</tt> or
  # <tt>:textile</tt>. It defaults to <tt>:html</tt>.
  #
  # TODO: implement correcly the 'Help' button click
  def help(content = nil, type = :html, &block)

    if content.nil?
      return '' if block.nil?
      content = capture(&block)
    end

    if type == :textile
      content = RedCloth.new(content).to_html
    end

    # TODO: implement this button, and add style='display: none' to the help
    # message DIV
    button = link_to_function(_('Help'), "alert('change me, Leandro!')")

    text = content_tag('div', button + content_tag('div', content, :class => 'help_message', :style => 'display: none;'), :class => 'help_box')

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
  def virtual_community_identification
    content_tag('div', @virtual_community.name, :id => 'virtual_community_identification')
  end

  # TODO: test this helper
  # TODO: remove the absolute path
  def link_to_cms(text, profile = nil, options = {})
    profile ||= current_user.login
    link_to text, cms_path(:profile => profile), options
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
  # FIXME: uncomment "My enterprises" links
  def user_links
    links = [
       ( link_to(_('My account'), { :controller => 'account' }) ),
       ( link_to_myprofile(_('My profile'), { :controller => 'profile_editor' }) ),
       ( link_to_homepage(_('My home page')) ),
       ( link_to_cms(_('Manage content')) ),
       ( link_to (_('Manage layout')), :controller => 'edit_template' ),
       #( link_to_myprofile(_('My enterprises'), { :controller => 'enterprise' }) ),
    ].join("\n")
    content_tag('span', links, :id => 'user_links')
  end

  def header
    virtual_community_identification + "\n" + login_or_register_or_logout
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

  # FIXME
  def footer
    'nothing in the footer yet'
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
    content_tag('div', content_tag('div', content_tag('label', label)) + html_for_field, :class => 'formfield') 
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
          "<div class='formfield'>" + "<div><label for='\#{field}'>" + (column ? column.human_name : _(object.class.name + "|" + field.to_s.humanize)) + "</label></div>" + super + "</div>"
        end
      END_SRC
      class_eval src, __FILE__, __LINE__
    end
  end

end
