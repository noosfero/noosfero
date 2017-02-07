class MenuBlock < Block

  include SanitizeHelper
  def self.description
    _('Menu Block')
  end

  def help
    _('This block can be used to display a menu for profiles.')
  end

  def self.pretty_name
    _('Menu Block')
  end

  def enabled_links(user)
    links = []
    links << {title: _('Activities'), controller: 'profile', action: 'activities'} if display_activities?(user)
    links << {title: _('About'), controller: 'profile', action: 'about'} if display_about?(user)
    links << {title: _('Communities'), controller: 'memberships', action: 'index'} if display_communities?(user)
    links << {title: _('People'), controller: 'friends', action: 'index'} if display_friends?(user)
    links << {title: _('People'), controller: 'profile_members', action: 'index'} if display_members?(user)
    links << {title: _('Control Panel')}.merge(owner.admin_url) if display_control_panel?(user)
    links
  end

  def api_content(options = {})
    links = self.enabled_links(options[:current_person])
    links
  end

  def display_api_content_by_default?
    true
  end

  protected

  def display_control_panel?(user)
    user && user.has_permission?('edit_profile', owner)
  end
    
  def display_activities?(user)
    AccessLevels.can_access?(owner.wall_access, user, owner)
  end

  def display_about?(user)
    owner.person?
  end

  def display_communities?(user)
    owner.person? && user && user.has_permission?(:manage_memberships, owner)
  end

  def display_friends?(user)
    owner.person? && user && user.has_permission?(:manage_friends, owner)
  end

  def display_members?(user)
    owner.community? && user && user.has_permission?(:manage_memberships, owner)
  end

end
