class MenuBlock < Block

  include SanitizeHelper

  attr_accessible :enabled_links, :api_content
  settings_items :enabled_links, type: Array, :default => []

  def self.description
    _('Menu Block')
  end

  def help
    _('This block can be used to display a menu for profiles.')
  end

  def self.pretty_name
    _('Menu Block')
  end

  def available_links
    links = []
    links << {title: _('Activities'), controller: 'profile', action: 'activities', condition: -> (user) { display_activities?(user) } }
    links << {title: _('About'), controller: 'profile', action: 'about', condition: -> (user) { display_about?(user) } }
    links << {title: _('Communities'), controller: 'memberships', action: 'index', condition: -> (user) { display_communities?(user) } }
    links << {title: _('People'), controller: 'friends', action: 'index', condition: -> (user) { display_friends?(user) } }
    links << {title: _('People'), controller: 'profile_members', action: 'index', condition: -> (user) { display_members?(user) } }
    links << {title: _('Control Panel'), condition: -> (user) { display_control_panel?(user) } }.merge(owner.admin_url)
    links
  end

  def enabled_links_for(user)
    filter_links user, enabled_links.empty? ? available_links : enabled_links
  end

  def api_content(options = {})
    {
      enabled_items: enabled_links_for(options[:current_person]),
      available_items: filter_links(options[:current_person], available_links)
    }
  end

  def api_content=(values = {})
    settings[:enabled_links] = values[:enabled_items]
  end

  def display_api_content_by_default?
    true
  end

  protected

  def filter_links(user, links)
    links.select { |link| permission_control(link, user) }
  end

  def display_control_panel?(user)
    user && user.has_permission?('edit_profile', owner)
  end

  def display_activities?(user)
    AccessLevels.can_access?(access_level, user, owner)
  end

  def access_level
    owner.person? ? AccessLevels::LEVELS[:users] : AccessLevels::LEVELS[:visitors]
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

  def display_article?(user)
    true
  end

  def permission_control(link, user)
    return true if !link[:controller] || !link[:action]
    available_link = available_links.find { |l| l[:controller] == link[:controller] && l[:action] == link[:action] }
    return available_link[:condition].call(user)
  end

end
