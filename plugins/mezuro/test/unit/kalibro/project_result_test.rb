require "test_helper"

require "#{Rails.root}/plugins/mezuro/test/fixtures/project_result_fixtures"

class ProjectResultTest < ActiveSupport::TestCase

  def setup
    @hash = ProjectResultFixtures.project_result_hash
    @project_result = ProjectResultFixtures.project_result
    
    @project_name = @project_result.project.name
    @date = @project_result.date
    @flag = DateTime.now.sec % 2 == 0 #random choose between true or false

    @request = {:project_name => @project_name}
    @request_with_date = {:project_name => @project_name, :date => @date}
    @flag_response = {:has_results => @flag}
    @result_response = {:project_result => @project_result.to_hash}
  end

  should 'create project result from hash' do
    assert_equal @project_result.analysis_time, Kalibro::ProjectResult.new(@hash).analysis_time
  end

  should 'convert project result to hash' do
    assert_equal @hash, @project_result.to_hash
  end

  should 'get last result' do
    Kalibro::ProjectResult.expects(:request).with('ProjectResult',:get_last_result_of, @request).returns(@result_response)
    assert_equal @project_result.analysis_time , Kalibro::ProjectResult.last_result(@project_name).analysis_time
  end

  should 'get first result' do
    Kalibro::ProjectResult.expects(:request).with('ProjectResult',:get_first_result_of, @request).returns(@result_response)
    assert_equal @project_result.analysis_time, Kalibro::ProjectResult.first_result(@project_name).analysis_time
  end

  should 'get first result after date' do
    Kalibro::ProjectResult.expects(:request).with('ProjectResult',:get_first_result_after, @request_with_date).returns(@result_response)
    assert_equal @project_result.analysis_time, Kalibro::ProjectResult.first_result_after(@project_name, @date).analysis_time
  end
  
  should 'get last result before date' do
    Kalibro::ProjectResult.expects(:request).with('ProjectResult',:get_last_result_before, @request_with_date).returns(@result_response)
    assert_equal @project_result.analysis_time, Kalibro::ProjectResult.last_result_before(@project_name, @date).analysis_time
  end
  
  should 'verify if project has results' do
    Kalibro::ProjectResult.expects(:request).with('ProjectResult',:has_results_for, @request).returns(@flag_response)
    assert_equal @flag, Kalibro::ProjectResult.has_results?(@project_name)
  end
  
  should 'verify if project has results before date' do
    Kalibro::ProjectResult.expects(:request).with('ProjectResult',:has_results_before, @request_with_date).returns(@flag_response)
    assert_equal @flag, Kalibro::ProjectResult.has_results_before?(@project_name, @date)
  end
  
  should 'verify if project has results after date' do
    Kalibro::ProjectResult.expects(:request).with('ProjectResult',:has_results_after, @request_with_date).returns(@flag_response)
    assert_equal @flag, Kalibro::ProjectResult.has_results_after?(@project_name, @date)
  end

  should 'retrieve formatted load time' do
    assert_equal '00:00:14', @project_result.formatted_load_time
  end

  should 'retrieve formatted analysis time' do
    assert_equal '00:00:01', @project_result.formatted_analysis_time
  end

  should 'retrive complex module' do
    assert_equal @hash[:source_tree][:child][0][:child].first, @project_result.node("org.Window").to_hash
  end

  should 'return source tree node when nil is given' do
    assert_equal @hash[:source_tree], @project_result.node(nil).to_hash 
  end
  
  should 'return source tree node when project name is given' do
    assert_equal @hash[:source_tree], @project_result.node(@project_result.project.name).to_hash 
  end

  should 'return correct node when module name is given' do
    assert_equal @hash[:source_tree][:child][2], @project_result.node("main").to_hash
  end

end
