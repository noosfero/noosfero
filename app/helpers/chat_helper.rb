module ChatHelper

  def user_status_menu(icon_class, status)
    links = [
      ['icon-menu-online', _('Online'), 'chat-connect'],
      ['icon-menu-busy', _('Busy'), 'chat-busy'],
      ['icon-menu-offline', _('Sign out of chat'), 'chat-disconnect'],
    ]
    content_tag('span',
      link_to(content_tag('span', status) + ui_icon('ui-icon-triangle-1-s'),
        '#',
        :onclick => 'toggleMenu(this); return false',
        :class => icon_class + ' simplemenu-trigger'
      ) +
      content_tag('ul',
        links.map{|link| content_tag('li', link_to(link[1], '#', :class => link[0], :id => link[2], 'data-jid' => current_user.jid), :class => 'simplemenu-item') }.join("\n"),
        :style => 'display: none; z-index: 100',
        :class => 'simplemenu-submenu'
      ),
      :class => 'user-status'
    )
  end

end
