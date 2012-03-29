require "test_helper"
require File.dirname(__FILE__) + '/fake_port'

class BaseToolClientTest < ActiveSupport::TestCase

  def setup
    fake_port = FakePort.new('BaseTool')
    Kalibro::Client::Port.expects(:new).with('BaseTool').returns(fake_port)
    @client = Kalibro::Client::BaseToolClient.new
  end

  should 'get base tool names' do
    assert_equal ['Analizo', 'Checkstyle'], @client.base_tool_names
  end

  should 'get base tool by name' do
    analizo = @client.base_tool('Analizo')
    assert_equal 'Analizo', analizo.name
    assert_equal 'Analizo description', analizo.description
    assert_equal 1, analizo.supported_metrics.size
    metric = analizo.supported_metrics[0]
    assert_equal 'Analizo', metric.origin
    assert_equal 'Analizo metric', metric.name
    assert_equal 'Analizo metric description', metric.description
    assert_equal 'METHOD', metric.scope
    assert_equal ['CPP', 'JAVA'], metric.languages
  end

end