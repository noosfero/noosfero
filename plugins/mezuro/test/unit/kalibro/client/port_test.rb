require "test_helper"
class PortTest < ActiveSupport::TestCase

  def setup
    @client = mock
    set_default_address
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

  private

  def set_default_address
    service_file = "#{RAILS_ROOT}/plugins/mezuro/SERVICE"
    File.open(service_file).each_line{ | line | @default_address = line }
  end

end