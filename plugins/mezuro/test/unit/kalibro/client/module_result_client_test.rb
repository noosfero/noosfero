require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/module_result_fixtures"

class ModuleResultClientTest < ActiveSupport::TestCase

  def setup
    @port = mock
    Kalibro::Client::Port.expects(:new).with('ModuleResult').returns(@port)
    @client = Kalibro::Client::ModuleResultClient.new
    @result = ModuleResultFixtures.create
  end

  should 'get module result' do
    date_string = '2012-01-10T16:07:15.442-02:00'
    date = DateTime.parse(date_string)
    request_body = {:project_name => 'Qt-Calculator', :module_name => 'main', :date => date_string}
    response = {:module_result => @result.to_hash}
    @port.expects(:request).with(:get_module_result, request_body).returns(response)
    assert_equal @result, @client.module_result('Qt-Calculator', 'main', date)
  end

  should 'get result history' do
    request_body = {:project_name => 'Qt-Calculator', :module_name => 'main'}
    response = {:module_result => @result.to_hash}
    @port.expects(:request).with(:get_result_history, request_body).returns(response)
    assert_equal [@result], @client.result_history('Qt-Calculator', 'main')
  end
end
