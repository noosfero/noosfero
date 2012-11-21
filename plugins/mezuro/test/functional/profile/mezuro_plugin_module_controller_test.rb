require 'test_helper'

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/module_result_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/repository_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/project_fixtures"

class MezuroPluginModuleControllerTest < ActionController::TestCase

  def setup
    @controller = MezuroPluginModuleController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    @profile = fast_create(Community)

    #@project_result = ProjectResultFixtures.project_result
    @module_result = ModuleResultFixtures.module_result
    @repository_url = RepositoryFixtures.repository.address
    @project = ProjectFixtures.project
    @date = "2012-04-13T20:39:41+04:00"
    
    #Kalibro::Project.expects(:all_names).returns([])
    @content = MezuroPlugin::ProjectContent.new(:profile => @profile, :project_id => @project.id)
    @content.expects(:send_project_to_service).returns(nil)
    @content.save

  end

  should 'get module result' do
  end

=begin
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
=end
end
