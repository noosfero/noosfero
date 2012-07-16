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
    @metric = NativeMetricFixtures.amloc
    @metric_configuration = MetricConfigurationFixtures.amloc_metric_configuration
    @metric_configuration_hash = MetricConfigurationFixtures.amloc_metric_configuration_hash
    @compound_metric_configuration = MetricConfigurationFixtures.sc_metric_configuration
    @configuration = ConfigurationFixtures.configuration
  end
  
  should 'test choose_base_tool' do
    create_configuration_content   
    Kalibro::BaseTool.expects(:all_names).returns(@base_tool.name)
    get :choose_base_tool, :profile => @profile.identifier, :id => @content.id
    assert_equal @base_tool.name, assigns(:base_tools)
    assert_equal @content, assigns(:configuration_content)
    assert_response 200
  end

  should 'test choose_metric' do
    create_configuration_content
    Kalibro::BaseTool.expects(:find_by_name).with(@base_tool.name).returns(@base_tool)
    @base_tool.expects(:supported_metrics).returns(@base_tool.supported_metric)
    get :choose_metric, :profile => @profile.identifier, :id => @content.id, :base_tool => @base_tool.name
    assert_equal @content, assigns(:configuration_content)
    assert_equal @base_tool.name, assigns(:base_tool)
    assert_equal @base_tool.supported_metric, assigns(:supported_metrics)
    assert_response 200
  end

  should 'test new_metric_configuration' do
    create_configuration_content
    Kalibro::BaseTool.expects(:find_by_name).with(@base_tool.name).returns(@base_tool)
    @base_tool.expects(:metric).with(@metric.name).returns(@metric)
    get :new_metric_configuration, :profile => @profile.identifier, :id => @content.id, :base_tool => @base_tool.name, :metric_name => @metric.name
    assert_equal @content, assigns(:configuration_content)
    assert_equal @metric, assigns(:metric)
    assert_response 200
  end
  
  
  should 'test new_compound_metric_configuration' do
    create_configuration_content
    Kalibro::Configuration.expects(:find_by_name).with(@content.name).returns(@configuration)
    @configuration.expects(:metric_configurations).returns(@configuration.metric_configuration)
    get :new_compound_metric_configuration, :profile => @profile.identifier, :id => @content.id
    assert_equal @content, assigns(:configuration_content)
    assert_equal @configuration.metric_configuration, assigns(:metric_configurations)
    assert_response 200
  end

  should 'test edit_metric_configuration' do
    create_configuration_content
    Kalibro::MetricConfiguration.expects(:find_by_configuration_name_and_metric_name).with(@configuration.name, @metric.name).returns(@metric_configuration)
    get :edit_metric_configuration, :profile => @profile.identifier, :id => @content.id, :metric_name => @metric.name
    assert_equal @content, assigns(:configuration_content)
    assert_equal @metric_configuration, assigns(:metric_configuration)
    assert_equal @metric_configuration.metric, assigns(:metric)
    assert_response 200
  end
  
  should 'test edit_compound_metric_configuration' do
    create_configuration_content
    Kalibro::MetricConfiguration.expects(:find_by_configuration_name_and_metric_name).with(@configuration.name, @metric.name).returns(@compound_metric_configuration)
    Kalibro::Configuration.expects(:find_by_name).with(@content.name).returns(@configuration)
    @configuration.expects(:metric_configurations).returns(@configuration.metric_configuration)
    get :edit_compound_metric_configuration, :profile => @profile.identifier, :id => @content.id, :metric_name => @metric.name
    assert_equal @content, assigns(:configuration_content)
    assert_equal @compound_metric_configuration, assigns(:metric_configuration)
    assert_equal @compound_metric_configuration.metric, assigns(:metric)
    assert_equal @configuration.metric_configuration, assigns(:metric_configurations)
    assert_response 200
  end
  
  should 'test create_metric_configuration' do
    create_configuration_content
    @metric_configuration.expects(:save).returns(true)
    MezuroPlugin::ConfigurationContent.expects(:validate_kalibro_configuration_name).returns(true)
    MezuroPlugin::ConfigurationContent.expects(:send_configuration_to_service).returns(true)
    get :create_metric_configuration, :profile => @profile.identifier, :id => @content.id, :metric_configuration => @metric_configuration_hash
    assert_response 302
  end
  
=begin
  should 'test compound metric creation' do
    create_configuration_content
    Kalibro::MetricConfiguration.expects(:new).returns(@metric_configuration_client)
    @metric_configuration_client.expects(:save)
    get :create_compound_metric_configuration, :profile => @profile.identifier, :id => @content.id, 
    :metric_configuration => { :code => @compound_metric_configuration.code, :weight => @compound_metric_configuration.weight, 
    :aggregation_form => @compound_metric_configuration.aggregation_form, :metric => { :name => @compound_metric_configuration.metric.name , 
    :description => @compound_metric_configuration.metric.description, :scope => @compound_metric_configuration.metric.scope, 
    :script => @compound_metric_configuration.metric.script}}
    assert_response 302
  end

  should 'test metric edition' do
    create_configuration_content
    Kalibro::MetricConfiguration.expects(:new).returns(@metric_configuration_client)
    @metric_configuration_client.expects(:metric_configuration).with(@configuration.name,@metric.name).returns(@metric_configuration)
    get :edit_metric_configuration, :profile => @profile.identifier, :id => @content.id, :metric_name => @metric.name
    assert_response 200
  end
  
  should 'test compound metric edition' do
    create_configuration_content
    configuration_client = mock
    Kalibro::MetricConfiguration.expects(:new).returns(@metric_configuration_client)
    Kalibro::Configuration.expects(:new).returns(configuration_client)
    configuration_client.expects(:configuration).with(@configuration.name).returns(@configuration)
    @metric_configuration_client.expects(:metric_configuration).with(@configuration.name,@metric.name).returns(@compound_metric_configuration)
    get :edit_compound_metric_configuration, :profile => @profile.identifier, :id => @content.id, :metric_name => @metric.name
    assert_response 200
  end

  should 'update metric configuration' do
    create_configuration_content
    Kalibro::MetricConfiguration.expects(:new).returns(@metric_configuration_client)
    Kalibro::MetricConfiguration.expects(:new).returns(@metric_configuration_client)
    @metric_configuration_client.expects(:metric_configuration).with(@configuration.name, @metric_configuration.metric.name).returns(@metric_configuration)
    @metric_configuration_client.expects(:save)
    get :update_metric_configuration, :profile => @profile.identifier, :id => @content.id, 
    :metric_configuration => { :code => @metric_configuration.code, :weight => @metric_configuration.weight, :aggregation => @metric_configuration.aggregation_form, 
    :metric => { :name => @metric.name, :origin => @metric.origin, :description => @metric.description, :scope => @metric.scope, :language => @metric.language }}
    assert_response 302
  end

  should 'update compound metric configuration' do
    create_configuration_content
    Kalibro::MetricConfiguration.expects(:new).returns(@metric_configuration_client)
    Kalibro::MetricConfiguration.expects(:new).returns(@metric_configuration_client)
    @metric_configuration_client.expects(:metric_configuration).with(@configuration.name, @compound_metric_configuration.metric.name).returns(@compound_metric_configuration)
    @metric_configuration_client.expects(:save)
    get :update_compound_metric_configuration, :profile => @profile.identifier, :id => @content.id, 
    :metric_configuration => { :code => @compound_metric_configuration.code, :weight => @compound_metric_configuration.weight, 
    :aggregation_form => @compound_metric_configuration.aggregation_form, :metric => { :name => @compound_metric_configuration.metric.name , 
    :description => @compound_metric_configuration.metric.description, :scope => @compound_metric_configuration.metric.scope, 
    :script => @compound_metric_configuration.metric.script}}
    assert_response 302
  end

  should 'assign configuration name and metric name to new range' do
    create_configuration_content
    get :new_range, :profile => @profile.identifier, :id => @content.id, :metric_name => @metric.name
    assert_equal assigns(:configuration_content), @content
    assert_equal assigns(:metric_name), @metric.name
  end

  should 'create instance range' do
    create_configuration_content
    Kalibro::MetricConfiguration.expects(:new).returns(@metric_configuration_client)
    Kalibro::MetricConfiguration.expects(:new).returns(@metric_configuration_client)
    @metric_configuration_client.expects(:metric_configuration).with(@configuration.name, @metric.name).returns(@metric_configuration)    
    @metric_configuration_client.expects(:save)
    range = @metric_configuration.ranges[0]
    get :create_range, :profile => @profile.identifier, :range => { :beginning => range.beginning, :end => range.end, :label => range.label,
    :grade => range.grade, :color => range.color, :comments => range.comments }, :id => @content.id, :metric_name => @metric.name
    assert assigns(:range).instance_of?(Kalibro::Range)
  end

  should 'redirect from remove metric configuration' do
    create_configuration_content
    Kalibro::MetricConfiguration.expects(:new).returns(@metric_configuration_client)
    @metric_configuration_client.expects(:remove)
    get :remove_metric_configuration, :profile => @profile.identifier, :id => @content.id, :metric_name => @metric.name
    assert_response 302
  end
  
  private
=end
  
  def create_configuration_content
    Kalibro::Configuration.expects(:all_names).returns([])
    @content = MezuroPlugin::ConfigurationContent.new(:profile => @profile, :name => @configuration.name)
    @content.expects(:send_configuration_to_service).returns(nil)
    @content.save
  end
end
