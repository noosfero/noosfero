
class OpenGraphPlugin::Base < Noosfero::Plugin

  def js_files
    [].map{ |j| "javascripts/#{j}" }
  end

  def stylesheet?
    true
  end

end

ActiveSupport.run_load_hooks :open_graph_plugin, OpenGraphPlugin

