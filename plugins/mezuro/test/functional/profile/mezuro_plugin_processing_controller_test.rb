require 'test_helper' 

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/processing_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/throwable_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/repository_fixtures"


class MezuroPluginProcessingControllerTest < ActionController::TestCase
  def setup
    @controller = MezuroPluginProcessingController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    @profile = fast_create(Community)

    @repository = RepositoryFixtures.repository
    @processing = ProcessingFixtures.processing

=begin
    @content = MezuroPlugin::ProjectContent.new(:profile => @profile, :name => @project.name, :repository_url => @repository_url)
    @content.expects(:send_project_to_service).returns(nil)
    @content.save
    @project_result = ProcessingFixtures.project_result
    
    Kalibro::Project.expects(:all_names).returns([])
=end
  end

  should 'render last processing state' do
    Kalibro::Processing.expects(:request).with(:last_processing_state, :repository_id => @repository.id).returns({:process_state => @processing.state})
    get :render_last_state, :profile => @profile.identifier, :repository_id => @repository.id
    assert_response 200
    assert_equal @processing.state, @response.body
  end

#TODO refatorar todos os testes
=begin
  should 'test project state with kalibro_error' do
    Kalibro::Project.expects(:request).with("Project", :get_project, :project_name => @project.name).returns({:project => @project.to_hash.merge({:error => ThrowableFixtures.throwable_hash})})
    get :project_state, :profile => @profile.identifier, :id => @content.id
    assert_response 200
    assert_equal "ERROR", @response.body
    assert_equal @content, assigns(:content)
  end

  should 'test project error' do
    Kalibro::Project.expects(:request).with("Project", :get_project, :project_name => @project.name).returns({:project => @project.to_hash.merge({:error => ThrowableFixtures.throwable_hash})})
    get :project_error, :profile => @profile.identifier, :id => @content.id
    assert_response 200
    assert_select('h3', 'ERROR')
    assert_equal @content, assigns(:content)
    assert_equal @project.name, assigns(:project).name
  end

  should 'test project result without date' do
    Kalibro::Processing.expects(:request).with("Processing", :get_last_result_of, {:project_name => @project.name}).returns({:project_result => @project_result.to_hash})
    get :project_result, :profile => @profile.identifier, :id => @content.id, :date => nil
    assert_equal @content, assigns(:content)
    assert_equal @project_result.project.name, assigns(:project_result).project.name
    assert_response 200
    assert_select('h4', 'Last Result')
  end
  
  should 'test project results from a specific date' do
    request_body = {:project_name => @project.name, :date => @date}
    Kalibro::Processing.expects(:request).with("Processing", :has_results_before, request_body).returns({:has_results => true})
    Kalibro::Processing.expects(:request).with("Processing", :get_last_result_before, request_body).returns({:project_result => @project_result.to_hash})
    get :project_result, :profile => @profile.identifier, :id => @content.id, :date => @date
    assert_equal @content, assigns(:content)
    assert_equal @project_result.project.name, assigns(:project_result).project.name
    assert_response 200
    assert_select('h4', 'Last Result')
  end

  should 'test project tree without date' do
    Kalibro::Processing.expects(:request).with("Processing", :get_last_result_of, {:project_name => @project.name}).returns({:project_result => @project_result.to_hash})
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
    Kalibro::Processing.expects(:request).with("Processing", :has_results_before, request_body).returns({:has_results => true})
    Kalibro::Processing.expects(:request).with("Processing", :get_last_result_before, request_body).returns({:project_result => @project_result.to_hash})
    get :project_tree, :profile => @profile.identifier, :id => @content.id, :module_name => @project.name, :date => @project_result.date
    assert_equal @content, assigns(:content)
    assert_equal @project.name, assigns(:project_name)
    assert_equal @project_result.source_tree.module.name, assigns(:source_tree).module.name    
	  assert_response 200
  end
=end
end
