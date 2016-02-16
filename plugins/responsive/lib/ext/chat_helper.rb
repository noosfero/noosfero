require_dependency 'chat_helper'

module ChatHelper

  protected

  module ResponsiveMethods

    def chat_user_status_menu icon_class, status
      return super unless theme_responsive?

      links = [
        ['icon-menu-online', _('Online'), 'chat-connect'],
        ['icon-menu-busy', _('Busy'), 'chat-busy'],
        ['icon-menu-offline', _('Sign out of chat'), 'chat-disconnect'],
      ]
      tag(:li, class: 'divider') + content_tag(:li, _('Chat'), class: 'dropdown-header') +
      links.map do |link|
        content_tag :li,
          link_to(content_tag(:i, nil, class: link[0]) + content_tag(:strong, link[1]), '#', id: link[2], 'data-jid' => user.jid)
      end.join
    end
  end

  include ResponsiveChecks
  if RUBY_VERSION >= '2.0.0'
    prepend ResponsiveMethods
  else
    extend ActiveSupport::Concern
    included { include ResponsiveMethods }
  end

end

