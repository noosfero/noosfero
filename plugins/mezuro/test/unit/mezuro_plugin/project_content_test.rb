require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/project_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/project_result_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/module_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/module_result_fixtures"

class ProjectContentTest < ActiveSupport::TestCase

  def setup
    @project = ProjectFixtures.project
    @content = ProjectFixtures.project_content
    @project_result = ProjectResultFixtures.project_result
    @module = ModuleFixtures.module
    @module_result = ModuleResultFixtures.module_result
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
    Kalibro::Project.expects(:request).with("Project", :get_project, :project_name => @project.name).returns({:project => @project.to_hash})
    assert_equal @project.name, @content.project.name
  end

  should 'get project result from service' do
    Kalibro::ProjectResult.expects(:request).with("ProjectResult", :get_last_result_of, {:project_name => @project.name}).returns({:project_result => @project_result.to_hash})
    assert_equal @project_result.load_time, @content.project_result.load_time
  end
  
  should 'get date result from service when has_result_before is true' do
    request_body = {:project_name => @project.name, :date => @project_result.date}
    Kalibro::ProjectResult.expects(:request).with("ProjectResult", :has_results_before, request_body).returns({:has_results => true})
    Kalibro::ProjectResult.expects(:request).with("ProjectResult", :get_last_result_before, request_body).returns({:project_result => @project_result.to_hash})
    assert_equal @project_result.load_time, @content.project_result_with_date(@project_result.date).load_time
  end

  should 'get date result from service when has_result_before is false' do
    request_body = {:project_name => @project.name, :date => @project_result.date}
    Kalibro::ProjectResult.expects(:request).with("ProjectResult", :has_results_before, request_body).returns({:has_results => false})
    Kalibro::ProjectResult.expects(:request).with("ProjectResult", :get_first_result_after, request_body).returns({:project_result => @project_result.to_hash})
    assert_equal @project_result.load_time, @content.project_result_with_date(@project_result.date).load_time
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
    assert_equal @module_result.grade, @content.module_result({:module_name => @module.name}).grade
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
    assert_equal @module_result.grade, @content.module_result({:module_name => @module.name, :date => @project_result.date}).grade
  end

  should 'get result history' do
    Kalibro::ModuleResult.expects(:request).with(
    'ModuleResult',
    :get_result_history,
      {
        :project_name => @project.name, 
        :module_name => @module.name
      }).returns({:module_result => @module_result.to_hash})
  	@content.result_history(@module.name)
  end

  should 'send project to service after saving' do
    @content.expects :send_project_to_service
    @content.run_callbacks :after_save
  end

  should 'send correct project to service' do
    hash = ProjectFixtures.project_hash
    hash.delete(:attributes!)
    hash.delete(:state)
    Kalibro::Project.expects(:create).with(hash).returns(@project)
    @project.expects(:process_project).with(@content.periodicity_in_days)
    @content.send :send_project_to_service
  end

  should 'destroy project from service' do
    Kalibro::Project.expects(:request).with("Project", :get_project, :project_name => @project.name).returns({:project => @project.to_hash})
    Kalibro::Project.expects(:request).with("Project", :remove_project, {:project_name => @project.name})
    @content.send :destroy_project_from_service
  end
  
  should 'not save a project with an existing project name in kalibro' do
 		Kalibro::Project.expects(:all_names).returns([@content.name])
		@content.send :validate_kalibro_project_name
		assert_equal "Project name already exists in Kalibro", @content.errors.on_base
	end
  
end
