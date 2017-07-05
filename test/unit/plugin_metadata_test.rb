require_relative "../test_helper"

class SolarSystemPlugin < Noosfero::Plugin
  def self.secret_default_metadata
    42
  end
end

class PluginMetadataTest < ActiveSupport::TestCase

  def setup
    @task = Task.new
    @profile = Profile.new
    @plugin = SolarSystemPlugin
  end

  attr_accessor :task, :profile, :plugin

  should 'store setttings on any model that offers metadata' do
    base = task
    metadata = Noosfero::Plugin::Metadata.new(base, plugin)
    metadata.star = 'sun'
    metadata.planets = 8
    assert_equal 'sun', base.metadata['solar_system_plugin']['star']
    assert_equal 8, base.metadata['solar_system_plugin']['planets']
    assert_equal 'sun', metadata.star
    assert_equal 8, metadata.planets

    base = profile
    metadata = Noosfero::Plugin::Metadata.new(base, plugin)
    metadata.star = 'sun'
    metadata.planets = 8
    assert_equal 'sun', base.metadata['solar_system_plugin']['star']
    assert_equal 8, base.metadata['solar_system_plugin']['planets']
    assert_equal 'sun', metadata.star
    assert_equal 8, metadata.planets
  end

  should 'save base on save' do
    task.expects(:save!)
    metadata = Noosfero::Plugin::Metadata.new(task, plugin)
    metadata.save!
  end

  should 'use default value defined on the plugin class' do
    metadata = Noosfero::Plugin::Metadata.new(profile, plugin)
    assert_equal 42, metadata.secret
  end

end
