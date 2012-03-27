require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/native_metric_fixtures"

class BaseToolClientTest < ActiveSupport::TestCase

  def setup
    @client = Kalibro::Client::BaseToolClient.new
  end

  should 'get base tool names' do
    assert_equal ['Analizo', 'Checkstyle'], @client.base_tool_names
  end

  should 'get base tool by name' do
    analizo = @client.base_tool('Analizo')
    amloc = NativeMetricFixtures.amloc
    amloc.languages = ["C", "CPP", "JAVA"]
    assert_includes analizo.supported_metrics, amloc
  end

end