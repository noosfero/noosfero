class VariablesPlugin < Noosfero::Plugin

  def self.plugin_name
    "Variables Plugin"
  end

  def self.plugin_description
    _("A set of simple variables to be used in a macro context")
  end

end

require_dependency 'variables_plugin/macros/profile'
