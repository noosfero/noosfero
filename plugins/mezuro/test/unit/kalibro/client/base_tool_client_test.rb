require "test_helper"
class BaseToolClientTest < ActiveSupport::TestCase

  def setup
    @port = mock
    Kalibro::Client::Port.expects(:new).with('BaseTool').returns(@port)
    @client = Kalibro::Client::BaseToolClient.new
  end

  should 'get base tool names (zero)' do
    @port.expects(:request).with(:get_base_tool_names).returns({})
    assert_equal [], @client.base_tool_names
  end

  should 'get base tool names (one)' do
    name = 'Analizo'
    @port.expects(:request).with(:get_base_tool_names).returns({:base_tool_name => name})
    assert_equal [name], @client.base_tool_names
  end

  should 'get base tool names' do
    names = ['Analizo', 'Checkstyle']
    @port.expects(:request).with(:get_base_tool_names).returns({:base_tool_name => names})
    assert_equal names, @client.base_tool_names
  end

  should 'get base tool by name' do
    analizo = BaseToolTest.analizo
    request_body = {:base_tool_name => 'Analizo'}
    @port.expects(:request).with(:get_base_tool, request_body).returns({:base_tool => analizo.to_hash})
    assert_equal analizo, @client.base_tool('Analizo')
  end

end