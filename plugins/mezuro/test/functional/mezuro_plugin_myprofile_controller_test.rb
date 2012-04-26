require 'test_helper'

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/error_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/base_tool_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/native_metric_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/metric_configuration_fixtures"

class MezuroPluginMyprofileControllerTest < ActionController::TestCase

  def setup
    @controller = MezuroPluginMyprofileController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    @profile = fast_create(Community)

    @collector = BaseToolFixtures.analizo
    @base_tool_client = Kalibro::Client::BaseToolClient.new
    @metric = NativeMetricFixtures.amloc
    @metric_configuration_client = Kalibro::Client::MetricConfigurationClient.new
    @metric_configuration = MetricConfigurationFixtures.amloc_configuration
  end

  should 'assign configuration name in choose_base_tool' do
    get :choose_base_tool, :profile => @profile.identifier, :configuration_name => "test name"
    assert_equal assigns(:configuration_name), "test name"
  end

  should 'create base tool client' do
    get :choose_base_tool, :profile => @profile.identifier, :configuration_name => "test name"
    assert assigns(:tool_names).instance_of?(Kalibro::Client::BaseToolClient)
  end

  should 'assign configuration and collector name in choose_metric' do
    Kalibro::Client::BaseToolClient.expects(:new).returns(@base_tool_client)
    @base_tool_client.expects(:base_tool).with(@collector.name).returns(@collector)
    get :choose_metric, :profile => @profile.identifier, :configuration_name => "test name", :collector_name => "Analizo"
    assert_equal assigns(:configuration_name), "test name"
    assert_equal assigns(:collector_name), "Analizo"
  end

  should 'get collector by name' do
    Kalibro::Client::BaseToolClient.expects(:new).returns(@base_tool_client)
    @base_tool_client.expects(:base_tool).with(@collector.name).returns(@collector)
    get :choose_metric, :profile => @profile.identifier, :configuration_name => "test name", :collector_name => "Analizo"
    assert_equal assigns(:collector), @collector
  end

  should 'get choosed native metric and configuration name' do
    Kalibro::Client::BaseToolClient.expects(:new).returns(@base_tool_client)
    @base_tool_client.expects(:base_tool).with(@collector.name).returns(@collector)
    get :new_metric_configuration, :profile => @profile.identifier, :configuration_name => "test name", :collector_name => "Analizo", :metric_name => @metric.name
    assert_equal assigns(:configuration_name), "test name"
    assert_equal assigns(:metric), @metric
  end

  should 'assign configuration name and get metric_configuration' do
    Kalibro::Client::MetricConfigurationClient.expects(:new).returns(@metric_configuration_client)
    @metric_configuration_client.expects(:metric_configuration).with("test name", @metric.name).returns(@metric_configuration)
    get :edit_metric_configuration, :profile => @profile.identifier, :configuration_name => "test name", :metric_name => @metric.name
    assert_equal assigns(:configuration_name), "test name"
    assert_equal assigns(:metric_configuration), @metric_configuration
    assert_equal assigns(:metric), @metric_configuration.metric
  end

  should 'test metric creation' do
    Kalibro::Client::MetricConfigurationClient.expects(:new).returns(@metric_configuration_client)
    @metric_configuration_client.expects(:save)
    get :create_metric_configuration, :profile => @profile.identifier, :configuration_name => "test name", :description => @metric.description,
    :scope => @metric.scope, :language => @metric.language, :metric => { :name => @metric.name, :origin => @metric.origin},
    :metric_configuration => { :code => @metric_configuration.code, :weight => @metric_configuration.code, :aggregation => @metric_configuration.aggregation_form }
    assert_equal assigns(:configuration_name), "test name"
    assert_response 302
  end

  should 'test metric edition' do
    Kalibro::Client::MetricConfigurationClient.expects(:new).returns(@metric_configuration_client)
    @metric_configuration_client.expects(:save)
    get :create_metric_configuration, :profile => @profile.identifier, :configuration_name => "test name", :description => @metric.description,
    :scope => @metric.scope, :language => @metric.language, :metric => { :name => @metric.name, :origin => @metric.origin},
    :metric_configuration => { :code => @metric_configuration.code, :weight => @metric_configuration.code, :aggregation => @metric_configuration.aggregation_form }
    assert_equal assigns(:configuration_name), "test name"
    assert_response 302
  end

  should 'assign configuration name and metric name to new range' do
    get :new_range, :profile => @profile.identifier, :configuration_name => "test name", :metric_name => @metric.name
    assert_equal assigns(:configuration_name), "test name"
    assert_equal assigns(:metric_name), @metric.name
  end

  should 'create instance range' do
    Kalibro::Client::MetricConfigurationClient.expects(:new).returns(@metric_configuration_client)
    @metric_configuration_client.expects(:metric_configuration).with("test name", @metric.name).returns(@metric_configuration)    
    @metric_configuration_client.expects(:save)
    range = @metric_configuration.ranges[0]
    get :create_range, :profile => @profile.identifier, :range => { :beginning => range.beginning, :end => range.end, :label => range.label,
    :grade => range.grade, :color => range.color, :comments => range.comments }, :configuration_name => "test name", :metric_name => @metric.name
    assert assigns(:range).instance_of?(Kalibro::Entities::Range)
  end

  should 'redirect from remove metric configuration' do
    Kalibro::Client::MetricConfigurationClient.expects(:new).returns(@metric_configuration_client)
    @metric_configuration_client.expects(:remove)
    get :remove_metric_configuration, :profile => @profile.identifier, :configuration_name => "test name", :metric_name => @metric.name
    assert_response 302
  end

end
