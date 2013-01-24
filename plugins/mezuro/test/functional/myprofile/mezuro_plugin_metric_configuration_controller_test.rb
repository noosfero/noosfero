require 'test_helper'

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/base_tool_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/metric_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/metric_configuration_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/configuration_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/reading_group_fixtures"

class MezuroPluginMetricConfigurationControllerTest < ActionController::TestCase

  def setup
    @controller = MezuroPluginMetricConfigurationController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    @profile = fast_create(Community)

    @configuration = ConfigurationFixtures.configuration
    @created_configuration = ConfigurationFixtures.created_configuration
    @configuration_hash = ConfigurationFixtures.configuration_hash

    @configuration_content = MezuroPlugin::ConfigurationContent.new(:profile => @profile, :name => @configuration.name, :configuration_id => 42)
    @configuration_content.expects(:send_configuration_to_service).returns(nil)
    @configuration_content.expects(:validate_configuration_name).returns(true)
    @configuration_content.stubs(:solr_save)
    @configuration_content.save
    
    @base_tool = BaseToolFixtures.base_tool
    @base_tool_hash = BaseToolFixtures.base_tool_hash
    
    @metric = MetricFixtures.amloc

    @reading_group = ReadingGroupFixtures.reading_group

    @metric_configuration = MetricConfigurationFixtures.amloc_metric_configuration
    @metric_configuration_hash = MetricConfigurationFixtures.amloc_metric_configuration_hash
    @created_metric_configuration = MetricConfigurationFixtures.created_metric_configuration
=begin
    @compound_metric_configuration = MetricConfigurationFixtures.sc_metric_configuration
    @compound_metric_configuration_hash = MetricConfigurationFixtures.sc_metric_configuration_hash
    
    
    @native_hash = @metric_configuration.to_hash.merge({:configuration_name => @metric_configuration.configuration_name})
    @native_hash.delete :attributes!    
    @compound_hash = @compound_metric_configuration.to_hash.merge({:configuration_name => @compound_metric_configuration.configuration_name})
    @compound_hash.delete :attributes!
=end
  end
  
  should 'test choose metric' do
    Kalibro::BaseTool.expects(:all).returns([@base_tool])
    get :choose_metric, :profile => @profile.identifier, :id => @configuration_content.id
    assert_equal @configuration_content, assigns(:configuration_content)
    assert_equal [@base_tool], assigns(:base_tools)
    assert_response 200
  end

  should 'test new native metric configuration' do
    Kalibro::BaseTool.expects(:find_by_name).with(@base_tool.name).returns(@base_tool)
    Kalibro::ReadingGroup.expects(:all).returns([@reading_group])
    get :new_native, :profile => @profile.identifier, :id => @configuration_content.id, :base_tool_name => @base_tool.name, :metric_name => @metric.name
    assert_equal @configuration_content, assigns(:configuration_content)
    assert_equal @metric.name, assigns(:metric).name
    assert_equal @base_tool.name, assigns(:base_tool_name)
    assert_equal [[@reading_group.name,@reading_group.id]], assigns(:reading_group_names_and_ids)
    assert_response 200
  end
  
  should 'test create native metric configuration' do
    #Kalibro::MetricConfiguration.expects(:new).returns(@created_metric_configuration) #FIXME need .with(some_hash).
    #@created_metric_configuration.expects(:save).returns(true)
=begin
    #TODO ARRUMAR ESTE TESTE!!!
    Kalibro::MetricConfiguration.expects(:request).with(:save_metric_configuration, {:metric_configuration => @metric_configuration.to_hash, :configuration_id => @configuration_content.configuration_id}).returns(@metric_configuration.id)
    get :create_native, :profile => @profile.identifier, :id => @configuration_content.id, :metric_configuration => @metric_configuration_hash
    assert_response 200
=end
  end
  
  should 'test edit native metric configuration' do
    Kalibro::MetricConfiguration.expects(:metric_configurations_of).with(@configuration.id).returns([@metric_configuration])
    Kalibro::ReadingGroup.expects(:all).returns([@reading_group])
    get :edit_native, :profile => @profile.identifier, :id => @configuration_content.id, :metric_configuration_id => @metric_configuration.id
    assert_equal @configuration_content, assigns(:configuration_content)
    assert_equal @metric_configuration.code, assigns(:metric_configuration).code
    assert_equal @metric_configuration.metric.name, assigns(:metric).name
    assert_equal [[@reading_group.name,@reading_group.id]], assigns(:reading_group_names_and_ids)
    assert_response 200
  end
=begin
  should 'test new compound metric configuration' do
    Kalibro::Configuration.expects(:request).with("Configuration", :get_configuration, {
      :configuration_name => @configuration_content.name}).returns({:configuration => @configuration_hash})
    get :new_compound_metric_configuration, :profile => @profile.identifier, :id => @configuration_content.id
    assert_equal @configuration_content, assigns(:configuration_content)
    assert_equal @configuration.metric_configuration[0].code, assigns(:metric_configurations)[0].code
    assert_response 200
  end

  
  should 'test edit compound metric configuration' do
    Kalibro::MetricConfiguration.expects(:request).with("MetricConfiguration", :get_metric_configuration, {
      :configuration_name => @configuration_content.name,
      :metric_name => @compound_metric_configuration.metric.name}).returns({:metric_configuration => @compound_metric_configuration_hash})
    Kalibro::Configuration.expects(:request).with("Configuration", :get_configuration, {:configuration_name => @configuration_content.name}).returns({:configuration => @configuration_hash})
    get :edit_compound_metric_configuration,
        :profile => @profile.identifier,
        :id => @configuration_content.id,
        :metric_name => @compound_metric_configuration.metric.name
    assert_equal @configuration_content, assigns(:configuration_content)
    assert_equal @compound_metric_configuration.code, assigns(:metric_configuration).code
    assert_equal @compound_metric_configuration.metric.name, assigns(:metric).name
    assert_equal @configuration.metric_configuration[0].code, assigns(:metric_configurations)[0].code
    assert_response 200
  end
  
  
  should 'test compound metric creation' do
    Kalibro::MetricConfiguration.expects(:request).with("MetricConfiguration", :save_metric_configuration, {
      :metric_configuration => @compound_metric_configuration.to_hash,
      :configuration_name => @compound_metric_configuration.configuration_name})
    get :create_compound_metric_configuration, :profile => @profile.identifier, :id => @configuration_content.id, 
      :metric_configuration => @compound_hash
    assert_response 302
  end

  should 'test update native metric configuration' do
    Kalibro::MetricConfiguration.expects(:request).with("MetricConfiguration", :get_metric_configuration, {
      :configuration_name => @configuration_content.name,
      :metric_name => @metric_configuration.metric.name}).returns({:metric_configuration => @metric_configuration_hash})
    Kalibro::MetricConfiguration.expects(:request).with("MetricConfiguration", :save_metric_configuration, {
        :metric_configuration => @metric_configuration.to_hash,
        :configuration_name => @metric_configuration.configuration_name})
    get :update_metric_configuration, :profile => @profile.identifier, :id => @configuration_content.id, 
      :metric_configuration => @native_hash
    assert_equal @configuration_content, assigns(:configuration_content)
    assert_response 302
  end

  should 'test update compound metric configuration' do
    Kalibro::MetricConfiguration.expects(:request).with("MetricConfiguration", :get_metric_configuration, {
      :configuration_name => @configuration_content.name,
      :metric_name => @compound_metric_configuration.metric.name}).returns({:metric_configuration => @compound_metric_configuration_hash})
    Kalibro::MetricConfiguration.expects(:request).with("MetricConfiguration", :save_metric_configuration, {
        :metric_configuration => @compound_metric_configuration.to_hash,
        :configuration_name => @compound_metric_configuration.configuration_name})
    get :update_compound_metric_configuration, :profile => @profile.identifier, :id => @configuration_content.id, 
    :metric_configuration => @compound_hash
    assert_equal @configuration_content, assigns(:configuration_content)
    assert_response 302
  end

  should 'test remove metric configuration' do
    Kalibro::MetricConfiguration.expects(:request).with("MetricConfiguration", :get_metric_configuration, {
      :configuration_name => @configuration_content.name,
      :metric_name => @metric.name}).returns({:metric_configuration => @metric_configuration_hash})
    Kalibro::MetricConfiguration.expects(:request).with("MetricConfiguration", :remove_metric_configuration, {
        :metric_name => @metric.name,
        :configuration_name => @metric_configuration.configuration_name})
    get :remove_metric_configuration, :profile => @profile.identifier, :id => @configuration_content.id, :metric_name => @metric.name
    assert_response 302
  end
=end
end
