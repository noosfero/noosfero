require 'test_helper'

class SolarSystemPlugin < Noosfero::Plugin
  def self.secret_default_setting
    42
  end
end

class PluginSettingsTest < ActiveSupport::TestCase

  def setup
    @environment = Environment.new
    @plugin = SolarSystemPlugin
    @settings = Noosfero::Plugin::Settings.new(@environment, @plugin)
  end

  attr_accessor :environment, :plugin, :settings

  should 'store setttings in environment' do
    settings.star = 'sun'
    settings.planets = 8
    assert_equal 'sun', environment.settings[:solar_system_plugin][:star]
    assert_equal 8, environment.settings[:solar_system_plugin][:planets]
    assert_equal 'sun', settings.star
    assert_equal 8, settings.planets
  end

  should 'save environment on save' do
    environment.expects(:save!)
    settings.save!
  end

  should 'use default value defined on the plugin class' do
    assert_equal 42, settings.secret
  end

end

