class LinkListBlock < Block

  ICONS = [
    ['no-icon', _('(No icon)')],
    ['edit', N_('Edit')],
    ['new', N_('New')],
    ['save', N_('Save')],
    ['send', N_('Send')],
    ['cancel', N_('Cancel')],
    ['add', N_('Add')],
    ['up', N_('Up')],
    ['down', N_('Down')],
    ['left', N_('Left')],
    ['right', N_('Right')],
    ['up-disabled', N_('Gray Up')],
    ['down-disabled', N_('Gray Down')],
    ['left-disabled', N_('Gray Left')],
    ['right-disabled', N_('Gray Right')],
    ['up-red', N_('Red Up')],
    ['search', N_('Search')],
    ['ok', N_('Ok')],
    ['login', N_('Login')],
    ['help', N_('Help')],
    ['spread', N_('Spread')],
    ['eyes', N_('Eyes')],
    ['photos', N_('Photos')],
    ['menu-people', N_('Person')],
    ['event', N_('Event')],
    ['forum', N_('Forum')],
    ['home', N_('Home')],
    ['product', N_('Package')],
    ['todo', N_('To do list')],
    ['chat', N_('Chat')]
  ]

  settings_items :links, Array, :default => []

  before_save do |block|
    block.links = block.links.delete_if {|i| i[:name].blank? and i[:address].blank?}
  end

  def self.description
    _('Links (static menu)')
  end

  def help
    _('This block can be used to create a menu of links. You can add, remove and update the links as you wish.')
  end

  def content
    block_title(title) +
    content_tag('ul',
      links.select{|i| !i[:name].blank? and !i[:address].blank?}.map{|i| content_tag('li', link_html(i))}
    )
  end

  def link_html(link)
    klass = 'icon-' + link[:icon] if link[:icon]
    sanitize_link(
      link_to(link[:name], expand_address(link[:address]), :class => klass)
    )
  end

  def expand_address(address)
    add = if owner.respond_to?(:identifier)
      address.gsub('{profile}', owner.identifier)
    else
      address
    end
    if add !~ /^[a-z]+:\/\// && add !~ /^\//
      'http://' + add
    else
      add
    end
  end

  def editable?
    true
  end

  def icons_options
    ICONS.map do |i|
      "<span title=\"#{i[1]}\" class=\"icon-#{i[0]}\" onclick=\"changeIcon(this, '#{i[0]}')\"></span>"
    end
  end

  private

  def sanitize_link(text)
    sanitizer = HTML::WhiteListSanitizer.new
    sanitizer.sanitize(text)
  end
end
