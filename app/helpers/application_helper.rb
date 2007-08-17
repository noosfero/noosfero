# Methods added to this helper will be available to all templates in the application.
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

  def link_to_cms(text, profile = nil, options = {})
    profile ||= current_user.login
    link_to text, "/cms/#{profile}", options
  end

  def link_to_profile(text, profile = nil, options = {})
    profile ||= current_user.login
    link_to text, "/#{profile}", options
  end

  # TODO: add the actual links
  # TODO: test this helper
  def user_links
    links = [
       ( link_to(_('My account'), { :controller => 'account' }) ),
       ( link_to_profile(_('My home page')) ),
       ( link_to_cms(_('Manage content')) ),
       ( link_to (_('Manage layout')), :controller => 'edit_template' ),
       ( link_to(_('My enterprises'), { :controller => 'enterprise' }) ),
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

end
