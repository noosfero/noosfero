class FbAppPlugin::Base < Noosfero::Plugin

  def stylesheet?
    true
  end

  def js_files
    ['fb_app.js'].map{ |j| "javascripts/#{j}" }
  end

  def head_ending
    return unless FbAppPlugin.config.present?
    lambda do
      tag 'meta', property: 'fb:app_id', content: FbAppPlugin.config[:app][:id]
    end
  end

  def control_panel_entries
    [FbAppPlugin::ControlPanel::FbApp]
  end

end

ActiveSupport.on_load :open_graph_plugin do
  OpenGraphPlugin::Stories.register_publisher FbAppPlugin::Publisher.default
end
ActiveSupport.on_load :metadata_plugin do
  MetadataPlugin::Controllers.class_eval do
    def fb_app_plugin_page_tab
      :@product
    end
  end
end

