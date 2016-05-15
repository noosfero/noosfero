class ElasticsearchPlugin < Noosfero::Plugin

  def self.plugin_name
    "ElasticsearchPlugin"
  end

  def self.plugin_description
    _("This plugin is used to communicate a elasticsearch to privide a search.")
  end

  # load all models to provide searchable fields
  require_relative "load_models"

end
