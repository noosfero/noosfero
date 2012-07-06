require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/configuration_fixtures"

class ConfigurationContentTest < ActiveSupport::TestCase

  def setup
    @configuration = ConfigurationFixtures.kalibro_configuration
    @content = MezuroPlugin::ConfigurationContent.new
    @content.name = @configuration.name
    @content.description = @configuration.description
  end

  should 'be an article' do
    assert_kind_of Article, @content
  end

  should 'provide proper short description' do
    assert_equal 'Kalibro configuration', MezuroPlugin::ConfigurationContent.short_description
  end

  should 'provide proper description' do
    assert_equal 'Sets of thresholds to interpret metrics', MezuroPlugin::ConfigurationContent.description
  end

  should 'have an html view' do
    assert_not_nil @content.to_html
  end

  should 'not save a configuration with an existing cofiguration name in kalibro' do
    client = mock
    Kalibro::Client::ConfigurationClient.expects(:new).returns(client)
    client.expects(:configuration_names).returns([@content.name.upcase])
    @content.send :validate_kalibro_configuration_name
    assert_equal "Configuration name already exists in Kalibro", @content.errors.on_base
  end

  should 'get configuration from service' do
    Kalibro::Client::ConfigurationClient.expects(:configuration).with(@content.name).returns(@configuration)
    assert_equal @configuration, @content.configuration
  end

  should 'send configuration to service after saving' do
    @content.expects :send_configuration_to_service
    @content.run_callbacks :after_save
  end

  should 'send correct configuration to service' do
    Kalibro::Client::ConfigurationClient.expects(:save).with(@content)
    @content.send :send_configuration_to_service
  end

  should 'remove configuration from service' do
    Kalibro::Client::ConfigurationClient.expects(:remove).with(@content.name)
    @content.send :remove_configuration_from_service
  end
  
end
