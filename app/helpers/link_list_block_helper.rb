module LinkListBlockHelper

  ICONS = {
    'no-icon'        => { :title => _('(No icon)'),  :icon => 'no-icon' },
    'edit'           => { :title => _('Edit'),       :icon => 'edit' },
    'new'            => { :title => _('New'),        :icon => 'plus-circle' },
    'save'           => { :title => _('Save'),       :icon => 'save' },
    'send'           => { :title => _('Send'),       :icon => 'share-square' },
    'cancel'         => { :title => _('Cancel'),     :icon => 'times' },
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
    'login'          => { :title => _('Login'),      :icon => 'sign-in-alt' },
    'help'           => { :title => _('Help'),       :icon => 'question' },
    'spread'         => { :title => _('Spread'),     :icon => 'paper-plane' },
    'eyes'           => { :title => _('Eyes'),       :icon => 'eye' },
    'photos'         => { :title => _('Photos'),     :icon => 'image' },
    'menu-people'    => { :title => _('Person'),     :icon => 'user' },
    'event'          => { :title => _('Event'),      :icon => 'calendar-alt' },
    'forum'          => { :title => _('Forum'),      :icon => 'users' },
    'home'           => { :title => _('Home'),       :icon => 'home' },
    'product'        => { :title => _('Package'),    :icon => 'shopping-bag' },
    'todo'           => { :title => _('To do list'), :icon => 'clipboard' },
    'chat'           => { :title => _('Chat'),       :icon => 'comments' },
    'enterprise'     => { :title => _('Enterprise'), :icon => 'building' },
    'blog'           => { :title => _('Blog'),       :icon => 'newspaper' },
    'community'      => { :title => _('Community\'s profile'),     :icon => 'users' },
  }

  def get_icon key
    if ICONS.has_key?(key)
      ICONS[key][:icon]
    else
      ICONS['no-icon'][:icon]
    end
  end

  def icons
    ICONS
  end

end
