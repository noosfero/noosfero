class ModuleResultClientTest < Test::Unit::TestCase

  def setup
    @port = mock
    Kalibro::Client::Port.expects(:new).with('ModuleResult').returns(@port)
    @client = Kalibro::Client::ModuleResultClient.new
    @result = ModuleResultTest.fixture
  end

  should 'get module result' do
    request_body = {:project_name => 'Qt-Calculator', :module_name => 'main', :date => '42'}
    response = {:module_result => @result.to_hash}
    @port.expects(:request).with(:get_module_result, request_body).returns(response)
    assert_equal @result, @client.module_result('Qt-Calculator', 'main', '42')
  end

  should 'get result history' do
    request_body = {:project_name => 'Qt-Calculator', :module_name => 'main'}
    response = {:module_result => @result.to_hash}
    @port.expects(:request).with(:get_result_history, request_body).returns(response)
    assert_equal [@result], @client.result_history('Qt-Calculator', 'main')
  end

end