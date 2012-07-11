require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/project_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/project_result_fixtures"

class ProjectContentTest < ActiveSupport::TestCase

  def setup
    @project = ProjectFixtures.project
    @content = ProjectFixtures.project_content
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
    Kalibro::Project.expects(:find_by_name).with(@content.name).returns(@project)
    assert_equal @project, @content.project
  end

  should 'get project result from service' do
    project_result = mock
    Kalibro::Client::ProjectResultClient.expects(:last_result).with(@content.name).returns(project_result)
    assert_equal project_result, @content.project_result
  end
  
  should 'get date result from service when has_result_before is true' do
    client = mock
    project_result = mock
    Kalibro::Client::ProjectResultClient.expects(:new).returns(client)
    client.expects(:has_results_before).with(@project.name, "2012-05-22T22:00:33+04:00").returns(true)
    client.expects(:last_result_before).with(@project.name, "2012-05-22T22:00:33+04:00").returns(project_result)
    assert_equal project_result, @content.get_date_result("2012-05-22T22:00:33+04:00")
  end

  should 'get date result from service when has_result_before is false' do
    client = mock
    project_result = mock
    Kalibro::Client::ProjectResultClient.expects(:new).returns(client)
    client.expects(:has_results_before).with(@project.name, "2012-05-22T22:00:33+04:00").returns(false)
    client.expects(:first_result_after).with(@project.name, "2012-05-22T22:00:33+04:00").returns(project_result)
    assert_equal project_result, @content.get_date_result("2012-05-22T22:00:33+04:00")
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
    project = mock
    Kalibro::Project.expects(:create).with(@content).returns(project)
    project.expects(:save).returns(true)
    Kalibro::Client::KalibroClient.expects(:process_project).with(@content.name, @content.periodicity_in_days)
    @content.send :send_project_to_service
  end

  should 'destroy project from service' do
    Kalibro::Project.expects(:destroy).with(@content.name)
    @content.send :destroy_project_from_service
  end
  
  should 'not save a project with an existing project name in kalibro' do
 		Kalibro::Project.expects(:all_names).returns([@content.name])
		@content.send :validate_kalibro_project_name
		assert_equal "Project name already exists in Kalibro", @content.errors.on_base
	end
  
  private

    def mock_project_client
      Kalibro::Project.expects(:find_by_name).with(@content.name).returns(@project)
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
