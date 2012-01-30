require 'test_helper'

class MezuroPluginProfileControllerTest < ActiveSupport::TestCase

  def setup
    @controller = MezuroPluginProfileController.new
    @request = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @profile = fast_create(Community)
    @profile_id = @profile.identifier
  end

  def test_metrics_for_unknown_module
    get :metrics, :profile => @profile_id, :id => 0
    assert_response 404
  end

  # TODO
  # def test_metrics_for_known_module
  #   @project = create_project(profile)
  #   @controller.stubs(:find_project).returns(@project)
  #   get :metrics, :profile => @profile_id, :id => project.id, :module_name => _
  #   assert_
  # end

  protected

  # returns a new ProjectContent for the given profile
  def create_project(profile)
    
  end

end
