class SocialStatisticsPlugin < Noosfero::Plugin

  def self.plugin_name
    _("Social Statistics")
  end

  def self.plugin_description
    _("Provides customized social statistics graphs and checks.")
  end

  def reserved_identifiers
    ['stats']
  end

  def user_menu_items(user)
    icon = '<i class="icon-menu-stats"></i><strong>' + _('Stats') + '</strong>'
    user.is_admin? ? proc { link_to(icon.html_safe, '/stats', :title => _("Manage the environment statistics."), :target => '_blank') } : nil
  end

end
