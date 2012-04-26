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
  
  should 'get project results from a specific date'
  
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

  private

  def create_project_content
    @content = MezuroPlugin::ProjectContent.new(:profile => @profile, :name => @name)
    @content.expects(:send_project_to_service).returns(nil)
    @content.save
  end

end
