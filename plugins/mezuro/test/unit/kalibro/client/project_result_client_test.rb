require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/project_result_fixtures"

class ProjectResultClientTest < ActiveSupport::TestCase

  def setup
    @port = mock
    Kalibro::Client::Port.expects(:new).with('ProjectResult').returns(@port)
    @client = Kalibro::Client::ProjectResultClient.new

    @result = ProjectResultFixtures.qt_calculator
    @project_name = @result.project.name
    @date = @result.date
    @flag = DateTime.now.sec % 2 == 0

    @request = {:project_name => @project_name}
    @request_with_date = {:project_name => @project_name, :date => @date}
    @flag_response = {:has_results => @flag}
    @result_response = {:project_result => @result.to_hash}
  end

  should 'retrieve if project has results' do
    @port.expects(:request).with(:has_results_for, @request).returns(@flag_response)
    assert_equal @flag, @client.has_results_for(@project_name)
  end

  should 'retrieve if project has results before date' do
    @port.expects(:request).with(:has_results_before, @request_with_date).returns(@flag_response)
    assert_equal @flag, @client.has_results_before(@project_name, @date)
  end

  should 'retrieve if project has results after date' do
    @port.expects(:request).with(:has_results_after, @request_with_date).returns(@flag_response)
    assert_equal @flag, @client.has_results_after(@project_name, @date)
  end

  should 'get first result of project' do
    @port.expects(:request).with(:get_first_result_of, @request).returns(@result_response)
    assert_equal @result, @client.first_result(@project_name)
  end

  should 'get last result of project' do
    @port.expects(:request).with(:get_last_result_of, @request).returns(@result_response)
    assert_equal @result, @client.last_result(@project_name)
  end

  should 'get first result of project after date' do
    @port.expects(:request).with(:get_first_result_after, @request_with_date).returns(@result_response)
    assert_equal @result, @client.first_result_after(@project_name, @date)
  end

  should 'get last result of project before date' do
    @port.expects(:request).with(:get_last_result_before, @request_with_date).returns(@result_response)
    assert_equal @result, @client.last_result_before(@project_name, @date)
  end

end