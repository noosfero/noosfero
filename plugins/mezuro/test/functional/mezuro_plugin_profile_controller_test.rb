require 'test_helper'

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/module_result_fixtures"

class MezuroPluginProfileControllerTest < ActionController::TestCase

  def setup
    @controller = MezuroPluginProfileController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    @profile = fast_create(Community)
  end

  should 'not find module result for inexistent project content' do
    get :module_result, :profile => @profile.id, :id => -1, :module_name => ''
    assert_response 404
  end

  should 'get metric results for a module' do
    create_project_content
    get :module_result, :profile => @profile.id, :id => @project_content.id, :module_name => @module_name
    assert_response 200
  end

  private

  def create_project_content
    @module_result = ModuleResultFixtures.create
    @module_name = @module_result.module.name
    @project_content = MezuroPlugin::ProjectContent.new(:profile => @profile, :name => @module_name)
    @project_content.expects(:send_project_to_service).returns(nil)
    @project_content.expects(:module_result).with(@module_name).returns(@module_result)
    @project_content.save
  end

end
