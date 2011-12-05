class MezuroPlugin < Noosfero::Plugin

  def self.plugin_name
    "Mezuro"
  end

  def self.plugin_description
    _("A metric analizer plugin.")
  end

  def content_types
    MezuroPlugin::ProjectContent
  end

  def view_path
    File.join(RAILS_ROOT, "plugins", "mezuro", "views")
  end

  def stylesheet?
    true
  end

  def js_files
    'javascripts/collapsable.js'
  end

end