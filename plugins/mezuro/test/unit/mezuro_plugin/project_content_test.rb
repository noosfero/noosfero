require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/project_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/project_content_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/processing_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/module_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/module_result_fixtures"

class ProjectContentTest < ActiveSupport::TestCase

  def setup
    @project = ProjectFixtures.project
    @project_content = ProjectContentFixtures.project_content
    @processing = ProcessingFixtures.processing
    @module = ModuleFixtures.module
    @module_result = ModuleResultFixtures.module_result
  end

  should 'provide proper short description' do
    assert_equal 'Mezuro project', MezuroPlugin::ProjectContent.short_description
  end

  should 'provide proper description' do
    assert_equal 'Software project tracked by Kalibro', MezuroPlugin::ProjectContent.description
  end

  should 'have an html view' do
    assert_not_nil @project_content.to_html
  end

  should 'get project from service' do
    Kalibro::Project.expects(:find).with(@project.id).returns(@project)
    assert_equal @project, @project_content.project
  end

  should 'add error when the project does not exist' do
    Kalibro::Project.expects(:find).with(@project.id).raises(Kalibro::Errors::RecordNotFound)
    @project_content.project

    assert_not_nil @project_content.errors
  end

=begin
  should 'get repositories of the project from service' do

  end

  should 'get module result from service without date' do
    date_with_milliseconds = Kalibro::ProjectResult.date_with_milliseconds(@project_result.date)
    Kalibro::ProjectResult.expects(:request).with('ProjectResult', :get_last_result_of, {:project_name => @project.name}).returns({:project_result => @project_result.to_hash})
    Kalibro::ModuleResult.expects(:request).with(
      'ModuleResult',
      :get_module_result,
      {
        :project_name => @project.name,
        :module_name => @module.name,
        :date => date_with_milliseconds
      }).returns({:module_result => @module_result.to_hash})
    assert_equal @module_result.grade, @project_content.module_result({:module_name => @module.name}).grade
  end

  should 'get module result from service with date' do
    date_with_milliseconds = Kalibro::ProjectResult.date_with_milliseconds(@project_result.date)
    request_body = {:project_name => @project.name, :date => @project_result.date}
    Kalibro::ProjectResult.expects(:request).with("ProjectResult", :has_results_before, request_body).returns({:has_results => false})
    Kalibro::ProjectResult.expects(:request).with("ProjectResult", :get_first_result_after, request_body).returns({:project_result => @project_result.to_hash})
    Kalibro::ModuleResult.expects(:request).with(
      'ModuleResult',
      :get_module_result,
      {
        :project_name => @project.name,
        :module_name => @module.name,
        :date => date_with_milliseconds
      }).returns({:module_result => @module_result.to_hash})
    assert_equal @module_result.grade, @project_content.module_result({:module_name => @module.name, :date => @project_result.date}).grade
  end

  should 'get result history' do
    Kalibro::ModuleResult.expects(:request).with(
    'ModuleResult',
    :get_result_history,
      {
        :project_name => @project.name,
        :module_name => @module.name
      }).returns({:module_result => @module_result.to_hash})
  	@project_content.result_history(@module.name)
  end

  should 'send project to service after saving' do
    @project_content.expects :send_project_to_service
    @project_content.run_callbacks :after_save
  end

  should 'send correct project to service' do
    hash = ProjectFixtures.project_hash
    hash.delete(:attributes!)
    hash.delete(:state)
    Kalibro::Project.expects(:create).with(hash).returns(@project)
    @project.expects(:process_project).with(@project_content.periodicity_in_days)
    @project_content.send :send_project_to_service
  end

  should 'destroy project from service' do
    Kalibro::Project.expects(:request).with("Project", :get_project, :project_name => @project.name).returns({:project => @project.to_hash})
    Kalibro::Project.expects(:request).with("Project", :remove_project, {:project_name => @project.name})
    @project_content.send :destroy_project_from_service
  end

  should 'not save a project with an existing project name in kalibro' do
 		Kalibro::Project.expects(:all_names).returns([@project_content.name])
		@project_content.send :validate_kalibro_project_name
		assert_equal "Project name already exists in Kalibro", @project_content.errors.on_base
	end
=end
end
