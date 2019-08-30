require_relative "../test_helper"

class SolarSystemPlugin < Noosfero::Plugin
  def self.secret_default_setting
    42
  end
end

class PluginSettingsTest < ActiveSupport::TestCase
  def setup
    @environment = Environment.new
    @profile = Profile.new
    @plugin = SolarSystemPlugin
  end

  attr_accessor :environment, :profile, :plugin

  should "store setttings on any model that offers settings" do
    base = environment
    settings = Noosfero::Plugin::Settings.new(base, plugin)
    settings.star = "sun"
    settings.planets = 8
    assert_equal "sun", base.settings[:solar_system_plugin][:star]
    assert_equal 8, base.settings[:solar_system_plugin][:planets]
    assert_equal "sun", settings.star
    assert_equal 8, settings.planets

    base = profile
    settings = Noosfero::Plugin::Settings.new(base, plugin)
    settings.star = "sun"
    settings.planets = 8
    assert_equal "sun", base.settings[:solar_system_plugin][:star]
    assert_equal 8, base.settings[:solar_system_plugin][:planets]
    assert_equal "sun", settings.star
    assert_equal 8, settings.planets
  end

  should "save base on save" do
    environment.expects(:save!)
    settings = Noosfero::Plugin::Settings.new(environment, plugin)
    settings.save!
  end

  should "use default value defined on the plugin class" do
    settings = Noosfero::Plugin::Settings.new(profile, plugin)
    assert_equal 42, settings.secret
  end

  should "create attributes with types setted" do
    base = environment
    settings = Noosfero::Plugin::Settings.new(base, plugin, { string_attribute: "test", boolean_attribute: "0" }, { boolean_attribute: "boolean" })

    assert_equal "test", base.settings[:solar_system_plugin][:string_attribute]
    assert_equal FalseClass, base.settings[:solar_system_plugin][:boolean_attribute].class
  end
end
