require 'test_helper'

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/error_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/base_tool_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/native_metric_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/metric_configuration_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/configuration_fixtures"

class MezuroPluginMyprofileControllerTest < ActionController::TestCase

  def setup
    @controller = MezuroPluginMyprofileController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    @profile = fast_create(Community)

    @base_tool = BaseToolFixtures.base_tool
    @base_tool_hash = BaseToolFixtures.base_tool_hash
    @metric = NativeMetricFixtures.amloc
    @metric_configuration = MetricConfigurationFixtures.amloc_metric_configuration
    @metric_configuration_hash = MetricConfigurationFixtures.amloc_metric_configuration_hash
    @compound_metric_configuration = MetricConfigurationFixtures.sc_metric_configuration
    @compound_metric_configuration_hash = MetricConfigurationFixtures.sc_metric_configuration_hash
    @configuration = ConfigurationFixtures.configuration
    @configuration_hash = ConfigurationFixtures.configuration_hash

    Kalibro::Configuration.expects(:all_names).returns([])
    @content = MezuroPlugin::ConfigurationContent.new(:profile => @profile, :name => @configuration.name)
    @content.expects(:send_kalibro_configuration_to_service).returns(nil)
    @content.stubs(:solr_save)
    @content.save

    @native_hash = @metric_configuration.to_hash.merge({:configuration_name => @metric_configuration.configuration_name})
    @native_hash.delete :attributes!    
    @compound_hash = @compound_metric_configuration.to_hash.merge({:configuration_name => @compound_metric_configuration.configuration_name})
    @compound_hash.delete :attributes!
  end

  should 'test new metric configuration' do
    Kalibro::BaseTool.expects(:request).with("BaseTool", :get_base_tool, {:base_tool_name => @base_tool.name}).returns({:base_tool => @base_tool_hash})
    get :new_metric_configuration, :profile => @profile.identifier, :id => @content.id, :base_tool => @base_tool.name, :metric_name => @metric.name
    assert_equal @content, assigns(:configuration_content)
    assert_equal @metric.name, assigns(:metric).name
    assert_response 200
  end

  should 'test new compound metric configuration' do
    Kalibro::Configuration.expects(:request).with("Configuration", :get_configuration, {:configuration_name => @content.name}).returns({:configuration => @configuration_hash})
    get :new_compound_metric_configuration, :profile => @profile.identifier, :id => @content.id
    assert_equal @content, assigns(:configuration_content)
    assert_equal @configuration.metric_configuration[0].code, assigns(:metric_configurations)[0].code
    assert_response 200
  end

  should 'test edit metric configuration' do
    Kalibro::MetricConfiguration.expects(:request).with("MetricConfiguration", :get_metric_configuration, {
      :configuration_name => @content.name,
      :metric_name => @metric_configuration.metric.name}).returns({:metric_configuration => @metric_configuration_hash})
    get :edit_metric_configuration, :profile => @profile.identifier, :id => @content.id, :metric_name => @metric.name
    assert_equal @content, assigns(:configuration_content)
    assert_equal @metric_configuration.code, assigns(:metric_configuration).code
    assert_equal @metric_configuration.metric.name, assigns(:metric).name
    assert_response 200
  end
  
  should 'test edit compound metric configuration' do
    Kalibro::MetricConfiguration.expects(:request).with("MetricConfiguration", :get_metric_configuration, {
      :configuration_name => @content.name,
      :metric_name => @compound_metric_configuration.metric.name}).returns({:metric_configuration => @compound_metric_configuration_hash})
    Kalibro::Configuration.expects(:request).with("Configuration", :get_configuration, {:configuration_name => @content.name}).returns({:configuration => @configuration_hash})
    get :edit_compound_metric_configuration,
        :profile => @profile.identifier,
        :id => @content.id,
        :metric_name => @compound_metric_configuration.metric.name
    assert_equal @content, assigns(:configuration_content)
    assert_equal @compound_metric_configuration.code, assigns(:metric_configuration).code
    assert_equal @compound_metric_configuration.metric.name, assigns(:metric).name
    assert_equal @configuration.metric_configuration[0].code, assigns(:metric_configurations)[0].code
    assert_response 200
  end
  
  should 'test create native metric configuration' do
    Kalibro::MetricConfiguration.expects(:request).with("MetricConfiguration", :save_metric_configuration, {
        :metric_configuration => @metric_configuration.to_hash,
        :configuration_name => @metric_configuration.configuration_name})
    get :create_metric_configuration,
        :profile => @profile.identifier,
        :id => @content.id,
        :metric_configuration => @native_hash
    assert_response 302
  end
  
  should 'test compound metric creation' do
    Kalibro::MetricConfiguration.expects(:request).with("MetricConfiguration", :save_metric_configuration, {
      :metric_configuration => @compound_metric_configuration.to_hash,
      :configuration_name => @compound_metric_configuration.configuration_name})
    get :create_compound_metric_configuration, :profile => @profile.identifier, :id => @content.id, 
    :metric_configuration => @compound_hash
    assert_response 302
  end

  should 'test update native metric configuration' do
    Kalibro::MetricConfiguration.expects(:request).with("MetricConfiguration", :get_metric_configuration, {
      :configuration_name => @content.name,
      :metric_name => @metric_configuration.metric.name}).returns({:metric_configuration => @metric_configuration_hash})
    Kalibro::MetricConfiguration.expects(:request).with("MetricConfiguration", :save_metric_configuration, {
        :metric_configuration => @metric_configuration.to_hash,
        :configuration_name => @metric_configuration.configuration_name})
    get :update_metric_configuration, :profile => @profile.identifier, :id => @content.id, 
      :metric_configuration => @native_hash
    assert_equal @content, assigns(:configuration_content)
    assert_response 302
  end

  should 'test update compound metric configuration' do
    Kalibro::MetricConfiguration.expects(:request).with("MetricConfiguration", :get_metric_configuration, {
      :configuration_name => @content.name,
      :metric_name => @compound_metric_configuration.metric.name}).returns({:metric_configuration => @compound_metric_configuration_hash})
    Kalibro::MetricConfiguration.expects(:request).with("MetricConfiguration", :save_metric_configuration, {
        :metric_configuration => @compound_metric_configuration.to_hash,
        :configuration_name => @compound_metric_configuration.configuration_name})
    get :update_compound_metric_configuration, :profile => @profile.identifier, :id => @content.id, 
    :metric_configuration => @compound_hash
    assert_equal @content, assigns(:configuration_content)
    assert_response 302
  end

  should 'test remove metric configuration' do
    Kalibro::MetricConfiguration.expects(:request).with("MetricConfiguration", :get_metric_configuration, {
      :configuration_name => @content.name,
      :metric_name => @metric.name}).returns({:metric_configuration => @metric_configuration_hash})
    Kalibro::MetricConfiguration.expects(:request).with("MetricConfiguration", :remove_metric_configuration, {
        :metric_name => @metric.name,
        :configuration_name => @metric_configuration.configuration_name})
    get :remove_metric_configuration, :profile => @profile.identifier, :id => @content.id, :metric_name => @metric.name
    assert_response 302
  end

end
