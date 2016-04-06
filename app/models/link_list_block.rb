class LinkListBlock < Block

  include SanitizeHelper

  attr_accessible :links

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

  TARGET_OPTIONS = [
    [N_('Same page'), '_self'],
    [N_('New tab'), '_blank'],
    [N_('New window'), '_new'],
  ]

  settings_items :links, type: Array, :default => []

  before_save do |block|
    block.links = block.links.delete_if {|i| i[:name].blank? and i[:address].blank?}
  end

  def self.description
    _('Links (static menu)')
  end

  def help
    _('This block can be used to create a menu of links. You can add, remove and update the links as you wish.')
  end

  def self.pretty_name
    _('Link list')
  end

  def expand_address(address)
    add = if owner.respond_to?(:identifier)
      address.gsub('{profile}', owner.identifier)
    elsif owner.is_a?(Environment) && owner.enabled?('use_portal_community') && owner.portal_community
      address.gsub('{portal}', owner.portal_community.identifier)
    else
      address
    end
    if add !~ /^[a-z]+:\/\// && add !~ /^\//
      '//' + add
    else
      if root = Noosfero.root
        if !add.starts_with?(root)
          add = root + add
        end
      end
      add
    end
  end

  def icons_options
    ICONS.map do |i|
      "<span title=\"#{i[1]}\" class=\"icon-#{i[0]}\" onclick=\"changeIcon(this, '#{i[0]}')\"></span>".html_safe
    end
  end

end
