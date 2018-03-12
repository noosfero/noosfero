class LinkListBlock < Block

  include SanitizeHelper

  attr_accessible :links

  ICONS = {
    'no-icon'        => { :title => _('(No icon)'),  :icon => 'no-icon' },
    'edit'           => { :title => _('Edit'),       :icon => 'edit' },
    'new'            => { :title => _('New'),        :icon => 'plus-circle' },
    'save'           => { :title => _('Save'),       :icon => 'save' },
    'send'           => { :title => _('Send'),       :icon => 'share-square' },
    'cancel'         => { :title => _('Cancel'),     :icon => 'remove' },
    'add'            => { :title => _('Add'),        :icon => 'plus' },
    'up'             => { :title => _('Up'),         :icon => 'arrow-up' },
    'down'           => { :title => _('Down'),       :icon => 'arrow-down' },
    'left'           => { :title => _('Left'),       :icon => 'arrow-left' },
    'right'          => { :title => _('Right'),      :icon => 'arrow-right' },
    'up-disabled'    => { :title => _('Gray up'),    :icon => 'arrow-up' },
    'down-disabled'  => { :title => _('Gray down'),  :icon => 'arrow-down' },
    'left-disabled'  => { :title => _('Gray left'),  :icon => 'arrow-left' },
    'right-disabled' => { :title => _('Gray Right'), :icon => 'arrow-right' },
    'up-read'        => { :title => _('Read up'),    :icon => 'quote-right' },
    'search'         => { :title => _('Search'),     :icon => 'search' },
    'ok'             => { :title => _('Ok'),         :icon => 'check' },
    'login'          => { :title => _('Login'),      :icon => 'sign-in' },
    'help'           => { :title => _('Help'),       :icon => 'question' },
    'spread'         => { :title => _('Spread'),     :icon => 'send' },
    'eyes'           => { :title => _('Eyes'),       :icon => 'eye' },
    'photos'         => { :title => _('Photos'),     :icon => 'image' },
    'menu-people'    => { :title => _('Person'),     :icon => 'user' },
    'event'          => { :title => _('Event'),      :icon => 'calendar' },
    'forum'          => { :title => _('Forum'),      :icon => 'users' },
    'home'           => { :title => _('Home'),       :icon => 'home' },
    'product'        => { :title => _('Package'),    :icon => 'shopping-bag' },
    'todo'           => { :title => _('To do list'), :icon => 'clipboard' },
    'chat'           => { :title => _('Chat'),       :icon => 'comments' },
    'enterprise'     => { :title => _('Enterprise'), :icon => 'building-o' },
    'blog'           => { :title => _('Blog'),       :icon => 'newspaper-o' },
    'community'      => { :title => _('Community\'s profile'),     :icon => 'users' },
  }

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

  def icons
    ICONS
  end

  def get_icon key
    if ICONS.has_key?(key)
      ICONS[key][:icon]
    else
      ICONS['no-icon'][:icon]
    end
  end

end
