module OpenGraphPlugin

  extend Noosfero::Plugin::ParentMethods

  def self.plugin_name
    I18n.t 'open_graph_plugin.lib.plugin.name'
  end

  def self.plugin_description
    I18n.t 'open_graph_plugin.lib.plugin.description'
  end

  def self.context
    Thread.current[:open_graph_context] || :open_graph
  end
  def self.context= value
    Thread.current[:open_graph_context] = value
  end

end

