class CustomRoutesPlugin < Noosfero::Plugin

  def self.plugin_name
    "Custom Routes Plugin"
  end

  def self.plugin_description
    _("Add and manage custom route mappings")
  end

  def stylesheet?
    true
  end

  def js_files
    ['js/custom_routes.js']
  end

end
