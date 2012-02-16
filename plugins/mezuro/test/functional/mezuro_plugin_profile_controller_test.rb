require 'test_helper'

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/module_result_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/project_result_fixtures"

class MezuroPluginProfileControllerTest < ActionController::TestCase

  def setup
    @controller = MezuroPluginProfileController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    @profile = fast_create(Community)

    @module_result = ModuleResultFixtures.create
    @module_name = @module_result.module.name
    @project_result = ProjectResultFixtures.qt_calculator
  end

  should 'not find module result for inexistent project content' do
    get :module_result, :profile => '', :id => -1, :module_name => ''
    assert_response 404
  end

  should 'get metric results for a module' do
    create_project_content
    Kalibro::Client::ModuleResultClient.expects(:module_result).with(@project_content, @module_name).returns(@module_result)
    get :module_result, :profile => @profile.identifier, :id => @project_content.id, :module_name => @module_name
    assert_response 200
    assert_select('h5', 'Metric results for: Qt-Calculator (APPLICATION)')
  end

  should 'get project results' do
    create_project_content
    Kalibro::Client::ProjectResultClient.expects(:last_result).with(@project_content.name).returns(@project_result)
    get :project_result, :profile => @profile.identifier, :id => @project_content.id
    assert_response 200
    assert_select('h3', 'LAST RESULT')
  end

  should 'get project state' do
    create_project_content
    Kalibro::Client::ProjectClient.expects(:project).with(@project_content.name).returns(@project_result.project)
    get :project_state, :profile => @profile.identifier, :id => @project_content.id
    assert_response 200
    assert_equal "READY", @response.body
  end

  private

  def create_project_content
    @project_content = MezuroPlugin::ProjectContent.new(:profile => @profile, :name => @module_name)
    @project_content.expects(:send_project_to_service).returns(nil)
    @project_content.save
  end

end
