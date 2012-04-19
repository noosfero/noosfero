require 'test_helper'

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/module_result_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/project_result_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/error_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/base_tool_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/native_metric_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/metric_configuration_fixtures"

class MezuroPluginProfileControllerTest < ActionController::TestCase

  def setup
    @controller = MezuroPluginProfileController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    @profile = fast_create(Community)

    @project_result = ProjectResultFixtures.qt_calculator
    @module_result = ModuleResultFixtures.create
    @project = @project_result.project
    @name = @project.name

    @collector = BaseToolFixtures.analizo
    @base_tool_client = Kalibro::Client::BaseToolClient.new
    @metric = NativeMetricFixtures.amloc
    @metric_configuration_client = Kalibro::Client::MetricConfigurationClient.new
    @metric_configuration = MetricConfigurationFixtures.amloc_configuration
  end

  should 'not find module result for inexistent project content' do
    get :module_result, :profile => '', :id => -1, :module_name => ''
    assert_response 404
  end

  should 'get project state' do
    create_project_content
    Kalibro::Client::ProjectClient.expects(:project).with(@name).returns(@project)
    get :project_state, :profile => @profile.identifier, :id => @content.id
    assert_response 200
    assert_equal @project.state, @response.body
  end

  should 'get error state if project has error' do
    create_project_content
    Kalibro::Client::ProjectClient.expects(:project).with(@name).returns(@project)
    @project.expects(:error).returns("")
    get :project_state, :profile => @profile.identifier, :id => @content.id
    assert_response 200
    assert_equal "ERROR", @response.body
  end

  should 'get project error' do
    create_project_content
    Kalibro::Client::ProjectClient.expects(:project).with(@name).returns(@project)
    @project.expects(:error).returns(ErrorFixtures.create)
    get :project_error, :profile => @profile.identifier, :id => @content.id
    assert_response 200
    assert_select('h3', 'ERROR')
  end

  should 'get project results' do
    create_project_content
    Kalibro::Client::ProjectResultClient.expects(:last_result).with(@name).returns(@project_result)
    get :project_result, :profile => @profile.identifier, :id => @content.id
    assert_response 200
    assert_select('h4', 'Last Result')
  end

  should 'get module result' do
    create_project_content
	module_result_client = mock
    Kalibro::Client::ProjectResultClient.expects(:last_result).with(@name).returns(@project_result)
	Kalibro::Client::ModuleResultClient.expects(:new).returns(module_result_client)
    module_result_client.expects(:module_result).with(@name, @name, @project_result.date).returns(@module_result)
    get :module_result, :profile => @profile.identifier, :id => @content.id, :module_name => @name
    assert_response 200
    assert_select('h5', 'Metric results for: Qt-Calculator (APPLICATION)')
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

  private

  def create_project_content
    @content = MezuroPlugin::ProjectContent.new(:profile => @profile, :name => @name)
    @content.expects(:send_project_to_service).returns(nil)
    @content.save
  end

end
