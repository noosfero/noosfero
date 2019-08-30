class ElasticsearchPlugin < Noosfero::Plugin
  def self.plugin_name
    "ElasticsearchPlugin"
  end

  def self.api_mount_points
    [ElasticsearchPlugin::API]
  end

  def self.plugin_description
    _("This plugin is used to communicate with elasticsearch engine.")
  end

  def stylesheet?
    true
  end

  def js_files
    ["categories", "jstree.min"].map { |file_name| "javascripts/#{file_name}" }
  end

  def search_controller_filters
    block = proc do
      case action_name
      when "contents"
        params[:selected_type] = :text_article
      when "index"
      when "articles"
        params[:selected_type] = :text_article
      else
        params[:selected_type] = action_name.singularize.to_sym
      end

      redirect_to controller: "elasticsearch_plugin", action: "search", params: params
    end

    [{ type: "before_action",
       method_name: "redirect_search_to_elastic",
       block: block }]
  end
end
