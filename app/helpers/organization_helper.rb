module OrganizationHelper
  
  def set_links
    [
      { name: _('Community\'s profile'), address: '/profile/{profile}',                icon: 'community' },
      { name: _('Invite Friends'),       address: '/profile/{profile}/invite/friends', icon: 'send'      },
      { name: _('Agenda'),               address: '/profile/{profile}/events',         icon: 'event'     },
      { name: _('Image gallery'),        address: '/{profile}/gallery',                icon: 'photos'    },
      { name: _('Blog'),                 address: '/{profile}/blog',                   icon: 'blog'      }
    ]
  end

end
