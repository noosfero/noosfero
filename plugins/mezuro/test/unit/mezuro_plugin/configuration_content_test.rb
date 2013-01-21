require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/configuration_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/configuration_content_fixtures"

class ConfigurationContentTest < ActiveSupport::TestCase

  def setup
    @configuration = ConfigurationFixtures.configuration
    @content = ConfigurationContentFixtures.configuration_content
    @created_configuration = ConfigurationFixtures.created_configuration
    @content_hash = ConfigurationContentFixtures.configuration_content_hash
    @configuration_hash = {:name => @content_hash[:name], :description => @content_hash[:description], :id => @content_hash[:configuration_id]}
    @created_content = ConfigurationContentFixtures.created_configuration_content
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
    assert_equal @configuration, @content.configuration
  end

  should 'send configuration to service after saving' do
    @content.expects :send_configuration_to_service
    @content.stubs(:solr_save)
    @content.run_callbacks :after_save
  end

  should 'create new configuration' do
    Kalibro::Configuration.expects(:create).with(:name => @created_content.name, :description => @created_content.description, :id => nil).returns(@configuration)
    @created_content.send :send_configuration_to_service
    assert_equal @configuration.id, @created_content.configuration_id
  end

=begin
  should 'clone configuration' do
    @content.configuration_to_clone_name = 'clone name'
    Kalibro::Configuration.expects(:create).with(:name => @content.configuration_id, :description => @content.description, :metric_configuration => @configuration.metric_configurations_hash)
    Kalibro::Configuration.expects(:find).with(@content.configuration_id).returns(nil)
    Kalibro::Configuration.expects(:find).with('clone name').returns(@configuration)
    @content.send :send_configuration_to_service
  end
=end

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
