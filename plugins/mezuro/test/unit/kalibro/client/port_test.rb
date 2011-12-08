class PortTest < Test::Unit::TestCase

  def setup
    @service_address = Kalibro::Client::Port.service_address
    @client = mock
    Savon::Client.expects(:new).with("#{@service_address}PortTestEndpoint/?wsdl").returns(@client)
    @port = Kalibro::Client::Port.new('PortTest')
  end

  should 'default address be localhost' do
    assert_equal 'http://localhost:8080/KalibroService/', @service_address
  end

  should 'request action and return response' do
    response_body = {:port_test_response_key => 'PortTest response value'}
    response_hash = {:port_test_action_response => response_body}
    response = mock
    response.expects(:to_hash).returns(response_hash)
    @client.expects(:request).with(:kalibro, :port_test_action).returns(response)

    assert_equal response_body, @port.request(:port_test_action)
  end

end