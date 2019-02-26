class FooPlugin < Noosfero::Plugin
  include Noosfero::Plugin::HotSpot

  def self.plugin_name
    "Foo"
  end

  def self.plugin_description
    _("A sample plugin to test autoload craziness.")
  end

  module Hotspots
    # -> Custom foo plugin hotspot
    # do something to extend the FooPlugin behaviour
    # receive params a, b and c
    # returns = boolean or something else
    def foo_plugin_my_hotspot(a, b, c)
    end

    # -> Custom title for foo profiles tab
    # returns = a string with a custom title
    def foo_plugin_tab_title
    end
  end

  # TODO:
  # Somehow this method crashes many tests because it is called
  # even on other plugins
  # 
  def profile_tabs
    title = 'Foo plugin tab' unless title

    {:title => title, :id => 'foo_plugin', :content => lambda {'Foo plugin random content'} }
  end

  def control_panel_entries
    [FooPlugin::Button]
  end

end
