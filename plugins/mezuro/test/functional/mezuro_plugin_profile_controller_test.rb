require 'test_helper'

require "#{Rails.root}/plugins/mezuro/test/fixtures/module_result_fixtures"
require "#{Rails.root}/plugins/mezuro/test/fixtures/project_result_fixtures"
require "#{Rails.root}/plugins/mezuro/test/fixtures/error_fixtures"
require "#{Rails.root}/plugins/mezuro/test/fixtures/repository_fixtures"

class MezuroPluginProfileControllerTest < ActionController::TestCase

  def setup
    @controller = MezuroPluginProfileController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    @profile = fast_create(Community)

    @project_result = ProjectResultFixtures.project_result
    @module_result = ModuleResultFixtures.module_result
    @repository_url = RepositoryFixtures.repository.address
    @project = @project_result.project
    @date = "2012-04-13T20:39:41+04:00"
    
    Kalibro::Project.expects(:all_names).returns([])
    @content = MezuroPlugin::ProjectContent.new(:profile => @profile, :name => @project.name, :repository_url => @repository_url)
    @content.expects(:send_project_to_service).returns(nil)
    @content.save
  end

  should 'test project state without kalibro_error' do
    Kalibro::Project.expects(:request).with("Project", :get_project, :project_name => @project.name).returns({:project => @project.to_hash})
    get :project_state, :profile => @profile.identifier, :id => @content.id
    assert_response 200
    assert_equal @content, assigns(:content)
  end

  should 'test project state with kalibro_error' do
    Kalibro::Project.expects(:request).with("Project", :get_project, :project_name => @project.name).returns({:project => @project.to_hash.merge({:error => ErrorFixtures.error_hash})})
    get :project_state, :profile => @profile.identifier, :id => @content.id
    assert_response 200
    assert_equal "ERROR", @response.body
    assert_equal @content, assigns(:content)
  end

  should 'test project error' do
    Kalibro::Project.expects(:request).with("Project", :get_project, :project_name => @project.name).returns({:project => @project.to_hash.merge({:error => ErrorFixtures.error_hash})})
    get :project_error, :profile => @profile.identifier, :id => @content.id
    assert_response 200
    assert_select('h3', 'ERROR')
    assert_equal @content, assigns(:content)
    assert_equal @project.name, assigns(:project).name
  end

  should 'test project result without date' do
    Kalibro::ProjectResult.expects(:request).with("ProjectResult", :get_last_result_of, {:project_name => @project.name}).returns({:project_result => @project_result.to_hash})
    get :project_result, :profile => @profile.identifier, :id => @content.id, :date => nil
    assert_equal @content, assigns(:content)
    assert_equal @project_result.project.name, assigns(:project_result).project.name
    assert_response 200
    assert_select('h4', 'Last Result')
  end
  
  should 'test project results from a specific date' do
    request_body = {:project_name => @project.name, :date => @date}
    Kalibro::ProjectResult.expects(:request).with("ProjectResult", :has_results_before, request_body).returns({:has_results => true})
    Kalibro::ProjectResult.expects(:request).with("ProjectResult", :get_last_result_before, request_body).returns({:project_result => @project_result.to_hash})
    get :project_result, :profile => @profile.identifier, :id => @content.id, :date => @date
    assert_equal @content, assigns(:content)
    assert_equal @project_result.project.name, assigns(:project_result).project.name
    assert_response 200
    assert_select('h4', 'Last Result')
  end


  should 'get module result without date' do
    date_with_milliseconds = Kalibro::ProjectResult.date_with_milliseconds(@project_result.date)
    Kalibro::ProjectResult.expects(:request).
      with("ProjectResult", :get_last_result_of, {:project_name => @project.name}).
      returns({:project_result => @project_result.to_hash})
    Kalibro::ModuleResult.expects(:request).
      with("ModuleResult", :get_module_result, {:project_name => @project.name, :module_name => @project.name, :date => date_with_milliseconds}).
      returns({:module_result => @module_result.to_hash})
    get :module_result, :profile => @profile.identifier, :id => @content.id, :module_name => @project.name, :date => nil
    assert_equal @content, assigns(:content)
    assert_equal @module_result.grade, assigns(:module_result).grade
    assert_response 200
    assert_select('h5', 'Metric results for: Qt-Calculator (APPLICATION)')
  end

  should 'get module result with a specific date' do
	  date_with_milliseconds = Kalibro::ProjectResult.date_with_milliseconds(@project_result.date)
    request_body = {:project_name => @project.name, :date => @project_result.date}
    Kalibro::ProjectResult.expects(:request).with("ProjectResult", :has_results_before, request_body).returns({:has_results => true})
    Kalibro::ProjectResult.expects(:request).with("ProjectResult", :get_last_result_before, request_body).returns({:project_result => @project_result.to_hash})
    Kalibro::ModuleResult.expects(:request).with("ModuleResult", :get_module_result, {:project_name => @project.name, :module_name => @project.name, :date => date_with_milliseconds}).returns({:module_result => @module_result.to_hash})
    get :module_result, :profile => @profile.identifier, :id => @content.id, :module_name => @project.name, :date => @project_result.date
    assert_equal @content, assigns(:content)
    assert_equal @module_result.grade, assigns(:module_result).grade
    assert_response 200
    assert_select('h5', 'Metric results for: Qt-Calculator (APPLICATION)')
  end

  should 'test project tree without date' do
    Kalibro::ProjectResult.expects(:request).with("ProjectResult", :get_last_result_of, {:project_name => @project.name}).returns({:project_result => @project_result.to_hash})
    Kalibro::Project.expects(:request).with("Project", :get_project, :project_name => @project.name).returns({:project => @project.to_hash})
  	get :project_tree, :profile => @profile.identifier, :id => @content.id, :module_name => @project.name, :date => nil
    assert_equal @content, assigns(:content)
    assert_equal @project.name, assigns(:project_name)
    assert_equal @project_result.source_tree.module.name, assigns(:source_tree).module.name
	  assert_response 200
  	assert_select('h2', /Qt-Calculator/)
  end

  should 'test project tree with a specific date' do
    request_body = {:project_name => @project.name, :date => @project_result.date}
    Kalibro::Project.expects(:request).with("Project", :get_project, :project_name => @project.name).returns({:project => @project.to_hash})
    Kalibro::ProjectResult.expects(:request).with("ProjectResult", :has_results_before, request_body).returns({:has_results => true})
    Kalibro::ProjectResult.expects(:request).with("ProjectResult", :get_last_result_before, request_body).returns({:project_result => @project_result.to_hash})
    get :project_tree, :profile => @profile.identifier, :id => @content.id, :module_name => @project.name, :date => @project_result.date
    assert_equal @content, assigns(:content)
    assert_equal @project.name, assigns(:project_name)
    assert_equal @project_result.source_tree.module.name, assigns(:source_tree).module.name    
	  assert_response 200
  end

  should 'test module metrics history' do
    Kalibro::ModuleResult.expects(:request).with("ModuleResult", :get_result_history, {:project_name => @project.name, :module_name => @project.name}).returns({:module_result => @module_result})
    get :module_metrics_history, :profile => @profile.identifier, :id => @content.id, :module_name => @project.name,
    :metric_name => @module_result.metric_result.first.metric.name.delete("() ")
    assert_equal @content, assigns(:content)
    assert_equal [[@module_result.metric_result[0].value, @module_result.date.to_s[0..9]]], assigns(:score_history)
    assert_response 200
  end
  
  should 'test grade history' do
    Kalibro::ModuleResult.expects(:request).with("ModuleResult", :get_result_history, {:project_name => @project.name, :module_name => @project.name}).returns({:module_result => @module_result})
    get :module_grade_history, :profile => @profile.identifier, :id => @content.id, :module_name => @project.name
    assert_equal @content, assigns(:content)
    assert_equal [[@module_result.grade, @module_result.date.to_s[0..9]]], assigns(:score_history)
    assert_response 200
  end

end
