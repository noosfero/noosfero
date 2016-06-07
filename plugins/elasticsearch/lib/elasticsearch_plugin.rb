class ElasticsearchPlugin < Noosfero::Plugin

  def self.plugin_name
    "ElasticsearchPlugin"
  end

  def self.plugin_description
    _("This plugin is used to communicate a elasticsearch to privide a search.")
  end

  def stylesheet?
    true
  end
end
