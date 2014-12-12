module ChatHelper

  def user_status_menu(icon_class, status)
    links = [
      ['icon-menu-online', _('Online'), 'chat-connect'],
      ['icon-menu-busy', _('Busy'), 'chat-busy'],
      ['icon-menu-offline', _('Sign out of chat'), 'chat-disconnect'],
    ]
    avatar = profile_image(user, :portrait, :class => 'avatar')
    content_tag('span',
      link_to(avatar + content_tag('span', user.name) + ui_icon('ui-icon-triangle-1-s'),
        '#',
        :onclick => 'toggleMenu(this); return false',
        :class => icon_class + ' simplemenu-trigger'
      ) +
      content_tag('ul',
        links.map{|link| content_tag('li', link_to(link[1], '#', :class => link[0], :id => link[2], 'data-jid' => user.jid), :class => 'simplemenu-item') }.join("\n"),
        :style => 'display: none; z-index: 100',
        :class => 'simplemenu-submenu'
      ),
      :class => 'user-status'
    )
  end

end
