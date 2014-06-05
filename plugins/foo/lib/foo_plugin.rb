class FooPlugin < Noosfero::Plugin

  def self.plugin_name
    "Foo"
  end

  def self.plugin_description
    _("A sample plugin to test autoload craziness.")
  end

  def control_panel_buttons
    {:title => 'Foo plugin button', :icon => '', :url => ''}
  end

  def profile_tabs
    {:title => 'Foo plugin tab', :id => 'foo_plugin', :content => lambda {'Foo plugin random content'} }
  end

end
