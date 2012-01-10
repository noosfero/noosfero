require "test_helper"
class PortTest < Test::Unit::TestCase

  def setup
    @default_address = 'http://localhost:8080/KalibroService/'
    @client = mock
    Savon::Client.expects(:new).with("#{@default_address}PortTestEndpoint/?wsdl").returns(@client)
    @port = Kalibro::Client::Port.new('PortTest')
  end

  should 'get default address' do
    assert_equal @default_address, @port.service_address
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