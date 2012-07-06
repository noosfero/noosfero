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

    @base_tool = BaseToolFixtures.analizo
    @base_tool_client = Kalibro::Client::BaseToolClient.new
    @metric = NativeMetricFixtures.amloc
    @metric_configuration_client = Kalibro::Client::MetricConfigurationClient.new
    @metric_configuration = MetricConfigurationFixtures.amloc_configuration
    @compound_metric_configuration = MetricConfigurationFixtures.sc_configuration
    @configuration = ConfigurationFixtures.kalibro_configuration
  end

  should 'assign configuration content in choose_base_tool' do
    create_configuration_content
    Kalibro::Client::BaseToolClient.expects(:base_tools).returns([])
    get :choose_base_tool, :profile => @profile.identifier, :id => @content.id
    assert_equal assigns(:configuration_content), @content
  end

  should 'assign configuration and base_tool name in choose_metric' do
    create_configuration_content
    Kalibro::Client::BaseToolClient.expects(:new).returns(@base_tool_client)
    @base_tool_client.expects(:base_tool).with(@base_tool.name).returns(@base_tool)
    get :choose_metric, :profile => @profile.identifier, :id => @content.id, :base_tool => @base_tool.name
    assert_equal @content, assigns(:configuration_content)
    assert_equal @base_tool.name, assigns(:base_tool)
  end

  should 'get base_tool by name' do
    create_configuration_content
    Kalibro::Client::BaseToolClient.expects(:new).returns(@base_tool_client)
    @base_tool_client.expects(:base_tool).with(@base_tool.name).returns(@base_tool)
    get :choose_metric, :profile => @profile.identifier, :id => @content.id, :base_tool => @base_tool.name
    assert_equal @base_tool.name, assigns(:base_tool)
  end

  should 'get chosen native metric and configuration name' do
    create_configuration_content
    Kalibro::Client::BaseToolClient.expects(:new).returns(@base_tool_client)
    @base_tool_client.expects(:base_tool).with(@base_tool.name).returns(@base_tool)
    get :new_metric_configuration, :profile => @profile.identifier, :id => @content.id, :base_tool => @base_tool.name, :metric_name => @metric.name
    assert_equal @content, assigns(:configuration_content)
    assert_equal @metric, assigns(:metric)
  end
  
  should 'call configuration client in new_compound_metric_configuration method' do
    create_configuration_content
    configuration_client = mock
    Kalibro::Client::ConfigurationClient.expects(:new).returns(configuration_client)
    configuration_client.expects(:configuration).with(@configuration.name).returns(@configuration)
    get :new_compound_metric_configuration, :profile => @profile.identifier, :id => @content.id
    assert_response 200
  end

  should 'assign configuration name and get metric_configuration' do
    create_configuration_content
    Kalibro::Client::MetricConfigurationClient.expects(:new).returns(@metric_configuration_client)
    @metric_configuration_client.expects(:metric_configuration).with(@configuration.name, @metric.name).returns(@metric_configuration)
    get :edit_metric_configuration, :profile => @profile.identifier, :id => @content.id, :metric_name => @metric.name
    assert_equal assigns(:configuration_content), @content
    assert_equal assigns(:metric_configuration), @metric_configuration
    assert_equal assigns(:metric), @metric_configuration.metric
  end
  
  should 'test metric creation' do
    create_configuration_content
    Kalibro::Client::MetricConfigurationClient.expects(:new).returns(@metric_configuration_client)
    @metric_configuration_client.expects(:save)
    get :create_metric_configuration, :profile => @profile.identifier, :id => @content.id, 
    :metric_configuration => { :code => @metric_configuration.code, :weight => @metric_configuration.code, :aggregation => @metric_configuration.aggregation_form, 
    :metric => { :name => @metric.name, :origin => @metric.origin, :description => @metric.description, :scope => @metric.scope, :language => @metric.language }}
    assert_response 302
  end
  
  should 'test compound metric creation' do
    create_configuration_content
    Kalibro::Client::MetricConfigurationClient.expects(:new).returns(@metric_configuration_client)
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
    Kalibro::Client::MetricConfigurationClient.expects(:new).returns(@metric_configuration_client)
    @metric_configuration_client.expects(:metric_configuration).with(@configuration.name,@metric.name).returns(@metric_configuration)
    get :edit_metric_configuration, :profile => @profile.identifier, :id => @content.id, :metric_name => @metric.name
    assert_response 200
  end
  
  should 'test compound metric edition' do
    create_configuration_content
    configuration_client = mock
    Kalibro::Client::MetricConfigurationClient.expects(:new).returns(@metric_configuration_client)
    Kalibro::Client::ConfigurationClient.expects(:new).returns(configuration_client)
    configuration_client.expects(:configuration).with(@configuration.name).returns(@configuration)
    @metric_configuration_client.expects(:metric_configuration).with(@configuration.name,@metric.name).returns(@compound_metric_configuration)
    get :edit_compound_metric_configuration, :profile => @profile.identifier, :id => @content.id, :metric_name => @metric.name
    assert_response 200
  end

  should 'update metric configuration' do
    create_configuration_content
    Kalibro::Client::MetricConfigurationClient.expects(:new).returns(@metric_configuration_client)
    Kalibro::Client::MetricConfigurationClient.expects(:new).returns(@metric_configuration_client)
    @metric_configuration_client.expects(:metric_configuration).with(@configuration.name, @metric_configuration.metric.name).returns(@metric_configuration)
    @metric_configuration_client.expects(:save)
    get :update_metric_configuration, :profile => @profile.identifier, :id => @content.id, 
    :metric_configuration => { :code => @metric_configuration.code, :weight => @metric_configuration.weight, :aggregation => @metric_configuration.aggregation_form, 
    :metric => { :name => @metric.name, :origin => @metric.origin, :description => @metric.description, :scope => @metric.scope, :language => @metric.language }}
    assert_response 302
  end

  should 'update compound metric configuration' do
    create_configuration_content
    Kalibro::Client::MetricConfigurationClient.expects(:new).returns(@metric_configuration_client)
    Kalibro::Client::MetricConfigurationClient.expects(:new).returns(@metric_configuration_client)
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
    Kalibro::Client::MetricConfigurationClient.expects(:new).returns(@metric_configuration_client)
    Kalibro::Client::MetricConfigurationClient.expects(:new).returns(@metric_configuration_client)
    @metric_configuration_client.expects(:metric_configuration).with(@configuration.name, @metric.name).returns(@metric_configuration)    
    @metric_configuration_client.expects(:save)
    range = @metric_configuration.ranges[0]
    get :create_range, :profile => @profile.identifier, :range => { :beginning => range.beginning, :end => range.end, :label => range.label,
    :grade => range.grade, :color => range.color, :comments => range.comments }, :id => @content.id, :metric_name => @metric.name
    assert assigns(:range).instance_of?(Kalibro::Entities::Range)
  end

  should 'redirect from remove metric configuration' do
    create_configuration_content
    Kalibro::Client::MetricConfigurationClient.expects(:new).returns(@metric_configuration_client)
    @metric_configuration_client.expects(:remove)
    get :remove_metric_configuration, :profile => @profile.identifier, :id => @content.id, :metric_name => @metric.name
    assert_response 302
  end
  
  private
  
  def create_configuration_content
    client = mock
    Kalibro::Client::ConfigurationClient.expects(:new).returns(client)
    client.expects(:configuration_names).returns([])
    @content = MezuroPlugin::ConfigurationContent.new(:profile => @profile, :name => @configuration.name)
    @content.expects(:send_configuration_to_service).returns(nil)
    @content.save
  end

end
