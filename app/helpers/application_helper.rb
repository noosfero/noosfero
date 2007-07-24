# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  ICONS_DIR_PATH = "#{RAILS_ROOT}/public/icons"


  # Generate a select option to choose one of the available icons themes.
  # The available icons themes are those in 'public/icons'
  def select_icons_theme(object, chosen_icons_theme = nil)
    return '' if object.nil?
    available_icons_themes = Dir.new("#{ICONS_DIR_PATH}").to_a - REJECTED_DIRS
    icons_theme_options = options_for_select(available_icons_themes.map{|icons_theme| [icons_theme, icons_theme] }, chosen_icons_theme)
    select_tag('icons_theme_name', icons_theme_options ) +
    change_icons_theme('icons_theme_name', object)
  end

  # Generate a observer to reload a page when a icons theme is selected
  def change_icons_theme(observed_field, object)
    observe_field( observed_field,
      :url => {:action => 'set_default_icons_theme'},
      :with =>"'icons_theme_name=' + escape(value) + '&object_id=' + escape(#{object.id})",
      :complete => "document.location.reload();"
    )
  end

  #Display a given icon passed as argument
  #The icon path should be '/icons/{icons_theme}/{icon_image}'
  def display_icon(icon , icons_theme = "default", options = {})
    image_tag("/icons/#{icons_theme}/#{icon}.png", options)
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
  def virtual_community_identification
    content_tag('div', @virtual_community.name, :id => 'virtual_community_identification')
  end

  # TODO: add the actual links
  # TODO: test this helper
  def user_links
    links = [
       [ _('My accont'), { :controller => 'account' } ],
       [ _('My profile'), { :controller => 'ble'} ],
       [ _('My groups'), { :controller => 'bli'} ],
    ].map do |link|
      link_to link[0], link[1]
    end.join(' ')
    content_tag('div', links, :id => 'user_links')
  end

end
