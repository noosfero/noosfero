class LinkListBlock < Block

  ICONS = [
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
    ['eyes', N_('Eyes')]
  ]

  settings_items :links, Array, :default => []

  before_save do |block|
    block.links = block.links.delete_if {|i| i[:name].blank? and i[:address].blank?}
  end

  def self.description
    _('Display a list of links.')
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
    link_to(link[:name], expand_address(link[:address]), :class => klass)
  end

  def expand_address(address)
    if owner.respond_to?(:identifier)
      address.gsub('{profile}', owner.identifier)
    else
      address
    end
  end

  def editable?
    true
  end

  def icons_options(selected = nil)
    ICONS.map do |i|
      select = "selected='1'" if i[0] == selected
      "<option class='icon-#{i[0]}' value='#{i[0]}' #{select}>#{i[1]}</option>"
    end
  end

end
