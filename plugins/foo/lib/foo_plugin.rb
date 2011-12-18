require_dependency 'foo_plugin/ext/profile'

class FooPlugin < Noosfero::Plugin

  def self.plugin_name
    "Foo"
  end

  def self.plugin_description
    _("A sample plugin to test autoload craziness.")
  end

end
