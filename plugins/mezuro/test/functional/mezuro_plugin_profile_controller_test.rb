require 'test_helper'

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/module_result_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/project_result_fixtures"

class MezuroPluginProfileControllerTest < ActionController::TestCase

  def setup
    @controller = MezuroPluginProfileController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    @profile = fast_create(Community)
    @profile_id = @profile.identifier

    @module_result = ModuleResultFixtures.create
    @project_result = ProjectResultFixtures.qt_calculator
    @project = @project_result.project
  end

#  def test_metrics_for_unknown_project
#    get :metrics, :profile => @profile_id
#    assert_response 404
#  end
#
#  def test_metric_unknown_module
#    get :metrics, :profile => @profile_id, :id => @project_content.id, :module_name => 'veryunlikelyname'
#    assert_response 404
#  end


  def test_metrics_for_known_module
    project_content = create_project_content(@profile)
    project_name = project_content.name
    module_name = project_name
    Kalibro::Client::ProjectResultClient.expects(:last_result).with(project_name).returns(@project_result)
    Kalibro::Client::ModuleResultClient.expects(:module_result).with(project_content, module_name).
      returns(@module_result)
    get :metrics, :profile => @profile_id, :id => project_content.id, :module_name => module_name
    assert_response 200
    # assert_tag # TODO
  end

  protected

  # returns a new ProjectContent for the given profile
  def create_project_content(profile)
    project_content = MezuroPlugin::ProjectContent.new(:profile => profile, :name => @project.name)
    Kalibro::Client::ProjectClient.expects(:save).with(project_content)
    Kalibro::Client::KalibroClient.expects(:process_project).with(project_content.name)
    project_content.save

#    MezuroPlugin::ProjectContent.any_instance.stubs(:project_content).returns(project_content)
    project_content
  end
 
  #TODO Adicionar module result manualmente
  #TODO Ver testes do project content, refatorar o project content em cima dos testes
  #TODO Repensar design OO: nao amarrar o project_content ao webservice. Criar um modelo abstrato do webservice
end
