require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/project_fixtures"

class ProjectContentTest < ActiveSupport::TestCase

  def setup
    @project = ProjectFixtures.qt_calculator
    @content = MezuroPlugin::ProjectContent.new
    @content.name = @project.name
    @content.license = @project.license
    @content.description = @project.description
    @content.repository_type = @project.repository.type
    @content.repository_url = @project.repository.address
    @content.configuration_name = @project.configuration_name
    @content.periodicity_in_days = 1
  end

  should 'be an article' do
    assert_kind_of Article, @content
  end

  should 'provide proper short description' do
    assert_equal 'Kalibro project', MezuroPlugin::ProjectContent.short_description
  end

  should 'provide proper description' do
    assert_equal 'Software project tracked by Kalibro', MezuroPlugin::ProjectContent.description
  end

  should 'have an html view' do
    assert_not_nil @content.to_html
  end

  should 'get project from service' do
    Kalibro::Client::ProjectClient.expects(:project).with(@content.name).returns(@project)
    assert_equal @project, @content.project
  end

  should 'get project result from service' do
    project_result = mock
    Kalibro::Client::ProjectResultClient.expects(:last_result).with(@content.name).returns(project_result)
    assert_equal project_result, @content.project_result
  end

  should 'get module result from service' do
    mock_project_client
    project_result = mock_project_result_client
    module_name = 'My module name'
    module_result_client = mock
    module_result = Kalibro::Entities::ModuleResult.new
    @content.expects(:module_result_client).returns(module_result_client)
    module_result_client.expects(:module_result).with(@project.name, module_name, project_result.date).
returns(module_result)
    assert_equal module_result, @content.module_result(module_name)
  end

  should 'get module result root when nil is given' do
    mock_project_client
    project_result = mock_project_result_client
    module_result_client = mock
    module_result = Kalibro::Entities::ModuleResult.new
    @content.expects(:module_result_client).returns(module_result_client)
    module_result_client.expects(:module_result).with(@project.name, @project.name, project_result.date).
returns(module_result)
    assert_equal module_result, @content.module_result(nil)
  end

  should 'get result history' do
    mock_project_client
    module_name = 'Fake Name'
  	module_result_client = mock
    module_result_client.expects(:result_history).with(@project.name, module_name)
  	@content.expects(:module_result_client).returns(module_result_client)
  	@content.result_history(module_name)
  end

  should 'send project to service after saving' do
    @content.expects :send_project_to_service
    @content.run_callbacks :after_save
  end

  should 'send correct project to service' do
    Kalibro::Client::ProjectClient.expects(:save).with(@content)
    Kalibro::Client::KalibroClient.expects(:process_project).with(@content.name, @content.periodicity_in_days)
    @content.send :send_project_to_service
  end

  should 'remove project from service' do
    Kalibro::Client::ProjectClient.expects(:remove).with(@content.name)
    @content.send :remove_project_from_service
  end
  
  should 'not save a project with an existing project name in kalibro' do
		Kalibro::Client::ProjectClient.expects(:project).with(@content.name).returns(mock)
		@content.send :validate_kalibro_project_name
		assert_equal @content.errors.on_base, "Project name already exists in Kalibro"
	end
  
  private

    def mock_project_client
      Kalibro::Client::ProjectClient.expects(:project).with(@content.name).returns(@project)
    end
    
    def mock_project_result_client
      project_result = ProjectResultFixtures.qt_calculator
      Kalibro::Client::ProjectResultClient.expects(:last_result).with(@content.name).returns(project_result)
      project_result
    end

	  def create_project_error
	      raise "Error on Kalibro" 
	  end

end
