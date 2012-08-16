require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/configuration_fixtures"

class ConfigurationContentTest < ActiveSupport::TestCase

  def setup
    @configuration = ConfigurationFixtures.configuration
    @content = ConfigurationFixtures.configuration_content("None")
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
    Kalibro::Configuration.expects(:all_names).returns([@content.name.upcase])
    @content.send :validate_kalibro_configuration_name
    assert_equal "Configuration name already exists in Kalibro", @content.errors.on_base
  end

  should 'get configuration from service' do
    Kalibro::Configuration.expects(:find_by_name).with(@content.name).returns(@configuration)
    assert_equal @configuration, @content.kalibro_configuration
  end

  should 'send configuration to service after saving' do
    @content.expects :send_kalibro_configuration_to_service
    @content.stubs(:solr_save)
    @content.run_callbacks :after_save
  end

  should 'create new configuration' do
    Kalibro::Configuration.expects(:create).with(:name => @content.name, :description => @content.description)
    Kalibro::Configuration.expects(:find_by_name).with(@content.name)
    @content.send :send_kalibro_configuration_to_service
  end
  
  should 'clone configuration' do
    @content.configuration_to_clone_name = 'clone name'
    Kalibro::Configuration.expects(:create).with(:name => @content.name, :description => @content.description, :metric_configuration => @configuration.metric_configurations_hash)
    Kalibro::Configuration.expects(:find_by_name).with(@content.name).returns(nil)
    Kalibro::Configuration.expects(:find_by_name).with('clone name').returns(@configuration)
    @content.send :send_kalibro_configuration_to_service
  end

  should 'edit configuration' do
    Kalibro::Configuration.expects(:find_by_name).with(@content.name).returns(@configuration)
    @configuration.expects(:update_attributes).with(:description => @content.description)
    @content.send :send_kalibro_configuration_to_service
  end

  should 'send correct configuration to service but comunication fails' do
    Kalibro::Configuration.expects(:find_by_name).with(@content.name).returns(@configuration)
    @configuration.expects(:save).returns(false)
    @content.send :send_kalibro_configuration_to_service
  end

  should 'remove configuration from service' do
    Kalibro::Configuration.expects(:find_by_name).with(@content.name).returns(@configuration)
    @configuration.expects(:destroy)
    @content.send :remove_kalibro_configuration_from_service
  end

end
