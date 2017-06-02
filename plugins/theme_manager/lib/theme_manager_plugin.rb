class ThemeManagerPlugin < Noosfero::Plugin
  def self.plugin_name
    _("Theme Manager")
  end

  def self.plugin_description
    _("Allows to install themes from zip files.")
  end

  #TODO: nao linkar como config do plugin
  def admin_panel_links
    {title: _('Manage Themes'), url: {controller: 'theme_manager_plugin_admin', action: 'index'}}
  end

  def stylesheet?
    true
  end
end
