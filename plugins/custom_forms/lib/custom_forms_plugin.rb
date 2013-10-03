class CustomFormsPlugin < Noosfero::Plugin

  def self.plugin_name
    "Custom Forms"
  end

  def self.plugin_description
    _("Enables the creation of forms.")
  end

  def stylesheet?
    true
  end

  def control_panel_buttons
    {:title => _('Manage Forms'), :icon => 'custom-forms', :url => {:controller => 'custom_forms_plugin_myprofile'}}
  end

end
