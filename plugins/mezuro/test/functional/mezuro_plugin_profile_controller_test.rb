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
    
    @date = "2012-04-13T20:39:41+04:00"

  end

  should 'not find project state for inexistent project content' do
    get :project_state, :profile => '', :id => -1
    assert_response 404
  end
  
  should 'get project state' do
    create_project_content
    Kalibro::Client::ProjectClient.expects(:project).with(@name).returns(@project)
    get :project_state, :profile => @profile.identifier, :id => @content.id
    assert_response 200
  end

  should 'get error state if project has error' do
    create_project_content
    Kalibro::Client::ProjectClient.expects(:project).with(@name).returns(@project)
    @project.expects(:error).returns(ErrorFixtures.create)
    get :project_state, :profile => @profile.identifier, :id => @content.id
    assert_response 200
  end

  should 'not find content in project error for inexistent project content' do
    get :project_error, :profile => '', :id => -1
    assert_response 404
  end
  
  should 'get project error' do
    create_project_content
    Kalibro::Client::ProjectClient.expects(:project).with(@name).returns(@project)
    @project.expects(:error).returns(ErrorFixtures.create)
    get :project_error, :profile => @profile.identifier, :id => @content.id
    assert_response 200
    assert_select('h3', 'ERROR')
  end

  should 'not find project result for inexistent project content' do
    get :project_result, :profile => '', :id => -1
    assert_response 404
  end
  
  should 'get project results without date' do
    create_project_content
    Kalibro::Client::ProjectResultClient.expects(:last_result).with(@name).returns(@project_result)
    Kalibro::Client::ProjectClient.expects(:project).with(@name).returns(@project)
    get :project_result, :profile => @profile.identifier, :id => @content.id
    assert_response 200
    assert_select('h4', 'Last Result')
  end
  
  should 'get project results from a specific date' do
    create_project_content
    mock_project_result
    Kalibro::Client::ProjectClient.expects(:project).with(@name).returns(@project)
    get :project_result, :profile => @profile.identifier, :id => @content.id, :date => @project_result.date
    assert_response 200
  end

  should 'not find module result for inexistent project content' do
    get :module_result, :profile => '', :id => -1, :module_name => ''
    assert_response 404
  end

  should 'get module result without date' do
    create_project_content
    mock_module_result
    Kalibro::Client::ProjectResultClient.expects(:last_result).with(@name).returns(@project_result)
    Kalibro::Client::ProjectClient.expects(:project).with(@name).returns(@project)

    get :module_result, :profile => @profile.identifier, :id => @content.id, :module_name => @name
    assert_response 200
    assert_select('h5', 'Metric results for: Qt-Calculator (APPLICATION)')
  end

  should 'get module result from a specific date' do
	  create_project_content
    Kalibro::Client::ProjectClient.expects(:project).with(@name).returns(@project)
    mock_module_result
	  mock_project_result
	  get :module_result, :profile => @profile.identifier, :id => @content.id, :date => @project_result.date, :module_name => @name
	  assert_response 200
	  assert_select('h5', 'Metric results for: Qt-Calculator (APPLICATION)')
  end

  should 'not find project tree for inexistent project content' do
    get :project_tree, :profile => '', :id => -1, :module_name => ''
    assert_response 404
  end

  should 'get project tree without date' do
    create_project_content
    Kalibro::Client::ProjectResultClient.expects(:last_result).with(@name).returns(@project_result)
    Kalibro::Client::ProjectClient.expects(:project).with(@name).returns(@project)
  	get :project_tree, :profile => @profile.identifier, :id => @content.id, :module_name => @name
	  assert_response 200
  	assert_select('h2', /Qt-Calculator/)
  end

  should 'get project tree from a specific date' do
    create_project_content
  	mock_project_result
    Kalibro::Client::ProjectClient.expects(:project).with(@name).returns(@project)
    get :project_tree, :profile => @profile.identifier, :id => @content.id, :module_name => @name, :date => "2012-04-13T20:39:41+04:00"
	  assert_response 200
  end

  should 'get grade history' do
    create_project_content
    mock_module_result_history
    Kalibro::Client::ProjectClient.expects(:project).with(@name).returns(@project)
    get :module_grade_history, :profile => @profile.identifier, :id => @content.id, :module_name => @name
    assert_response 200
  end
      
  should 'not find metrics history for inexistent project content' do
    get :module_metrics_history, :profile => '', :id => -1, :module_name => ''
    assert_response 404
  end
  #copied from 'get grade history' test
  should 'get metrics history' do
    create_project_content
    mock_module_result_history
    Kalibro::Client::ProjectClient.expects(:project).with(@name).returns(@project)
    get :module_metrics_history, :profile => @profile.identifier, :id => @content.id, :module_name => @name,
    :metric_name => @module_result.metric_result.first.metric.name.delete("() ")
    assert_response 200
  end

  private

  def create_project_content
    client = mock
    @content = MezuroPlugin::ProjectContent.new(:profile => @profile, :name => @name)
    @content.expects(:send_project_to_service).returns(nil)
    Kalibro::Client::ProjectClient.expects(:new).returns(client)
    client.expects(:project_names).returns([])
    @content.save
  end
  
  def mock_project_result
    project_result_client = mock
	  Kalibro::Client::ProjectResultClient.expects(:new).returns(project_result_client)
	  project_result_client.expects(:has_results_before).returns(true)
	  project_result_client.expects(:last_result_before).returns(@project_result)
  end
  
  def mock_module_result
    module_result_client = mock
    Kalibro::Client::ModuleResultClient.expects(:new).returns(module_result_client)
    module_result_client.expects(:module_result).with(@name, @name, @project_result.date).returns(@module_result)
  end

  def mock_module_result_history
    module_result_client = mock
    module_result_client.expects(:result_history).with(@name, @name).returns([@module_result])
    Kalibro::Client::ModuleResultClient.expects(:new).returns(module_result_client)
  end
end
