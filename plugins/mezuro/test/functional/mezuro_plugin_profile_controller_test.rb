require 'test_helper'

class MezuroPluginProfileControllerTest < ActiveSupport::TestCase

  def setup
    @controller = MezuroPluginProfileController.new
    @request = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @profile = fast_create(Community)
    @profile_id = @profile.identifier
  end

#  def test_metrics_for_unknown_module
#    get :metrics, :profile => @profile_id, :id => 0
#    assert_response 404
#  end

#  def test_metric_unknown_module
#  get :metrics, :profile => @profile_id, :id => @project_content.id, :module_name => 'veryunlikelyname'
#  assert_response 404
#  end


#  def test_metrics_for_known_module
#    @project_content = create_project_content(@profile)
#    get :metrics, :profile => @profile_id, :id => @project_content.id, :module_name => @project_content.name
#    assert_response 200
#    # assert_tag # TODO
#  end

  protected

  # returns a new ProjectContent for the given profile
  def create_project_content(profile)
    project_content = MezuroPlugin::ProjectContent.create!(:profile => profile, :name => 'foo') 

    project = create_project(project_content.name)
    project_content.license = project.license
    project_content.description = project.description
    project_content.repository_type = project.repository.type
    project_content.repository_url = project.repository.address
    project_content.configuration_name = project.configuration_name

    MezuroPlugin::ProjectContent.any_instance.stubs(:project_content).returns(project_content)
    project_content
  end
  
  def create_project(name)
    project = Kalibro::Entities::Project.new
    project.name = name
    project.license = 'GPL'
    project.description = 'testing' 
    project.repository = crieate_repository
    project.configuration_name = 'Kalibro Default'
    project
  end

  def create_repository
    repository = Kalibro::Entities::Repository.new
    repository.type = 'git'
    repository.address = 'http://git.git'
    repository
  end
 
  #TODO Adicionar module result manualmente
  #TODO Ver testes do project content, refatorar o project content em cima dos testes
  #TODO Repensar design OO: nao amarrar o project_content ao webservice. Criar um modelo abstrato do webservice
end
