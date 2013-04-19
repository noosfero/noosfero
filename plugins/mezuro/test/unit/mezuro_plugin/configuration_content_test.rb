require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/configuration_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/configuration_content_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/metric_configuration_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/range_fixtures"

class ConfigurationContentTest < ActiveSupport::TestCase

  def setup
    @configuration = ConfigurationFixtures.configuration
    @content = ConfigurationContentFixtures.configuration_content
    @created_configuration = ConfigurationFixtures.created_configuration
    @content_hash = ConfigurationContentFixtures.configuration_content_hash
    @configuration_hash = {:name => @content_hash[:name], :description => @content_hash[:description], :id => @content_hash[:configuration_id]}
    @created_content = ConfigurationContentFixtures.created_configuration_content

    @metric_configuration = MetricConfigurationFixtures.amloc_metric_configuration
    @range = RangeFixtures.range
  end

  should 'be an article' do
    assert_kind_of Article, @content
  end

  should 'provide proper short description' do
    assert_equal 'Mezuro configuration', MezuroPlugin::ConfigurationContent.short_description
  end

  should 'provide proper description' do
    assert_equal 'Set of metric configurations to interpret a Kalibro project', MezuroPlugin::ConfigurationContent.description
  end

  should 'have an html view' do
    assert_not_nil @content.to_html
  end

  should 'not save a configuration with an existing cofiguration name in kalibro' do
    Kalibro::Configuration.expects(:all).returns([@configuration])
    @content.send :validate_configuration_name
    assert_equal "Configuration name already exists in Kalibro", @content.errors.on_base
  end

  should 'get configuration from service' do
    Kalibro::Configuration.expects(:find).with(@content.configuration_id).returns(@configuration)
    assert_equal @configuration, @content.kalibro_configuration
  end

  should 'send configuration to service after saving' do
    @content.expects :send_configuration_to_service
    @content.stubs(:solr_save)
    @content.run_callbacks :before_save
  end

  should 'create new configuration' do
    Kalibro::Configuration.expects(:create).with(:name => @created_content.name, :description => @created_content.description, :id => nil).returns(@configuration)
    @created_content.send :send_configuration_to_service
    assert_equal @configuration.id, @created_content.configuration_id
  end

  should 'clone configuration' do
    clone_id = @configuration.id
    @content.configuration_to_clone_id = clone_id
    Kalibro::Configuration.expects(:create).with(:id => @content.configuration_id, :name => @content.name, :description => @content.description).returns(@configuration)
    Kalibro::MetricConfiguration.expects(:metric_configurations_of).with(@configuration.id).returns([@metric_configuration])
    Kalibro::MetricConfiguration.expects(:request).returns(:metric_configuration_id => @metric_configuration.id)
    Kalibro::Range.expects(:ranges_of).with(@metric_configuration.id).returns([@range])
    @range.expects(:save).with(@metric_configuration.id).returns(true)
    @content.send :send_configuration_to_service
  end

  should 'edit configuration' do
    Kalibro::Configuration.expects(:new).with(@configuration_hash).returns(@configuration)
    @configuration.expects(:save).returns(true)
    @content.send :send_configuration_to_service
    assert_equal @configuration.id, @content.configuration_id
  end

  should 'send correct configuration to service but comunication fails' do
    Kalibro::Configuration.expects(:new).with(@configuration_hash).returns(@created_configuration)
    @created_configuration.expects(:save).returns(false)
    @content.send :send_configuration_to_service
  end

  should 'remove configuration from service' do
    Kalibro::Configuration.expects(:find).with(@content.configuration_id).returns(@configuration)
    @configuration.expects(:destroy)
    @content.send :remove_configuration_from_service
  end

end
