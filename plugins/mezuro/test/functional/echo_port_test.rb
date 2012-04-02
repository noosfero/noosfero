require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/base_tool_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/configuration_fixtures"

class EchoPortTest < ActiveSupport::TestCase

  def setup
    @port = Kalibro::Client::Port.new('Echo')
#    @port.service_address=('http://valinhos.ime.usp.br:50688/KalibroFake/');
    @port.service_address=('http://localhost:8080/KalibroFake/');
  end

  should 'echo base tool' do
    base_tool = BaseToolFixtures.analizo
    echoed = @port.request(:echo_base_tool, {:base_tool => base_tool.to_hash})[:base_tool]
    base_tool.name = "echo " + base_tool.name
    assert_equal base_tool, Kalibro::Entities::BaseTool.from_hash(echoed)
  end

  should 'echo configuration' do
    configuration = ConfigurationFixtures.kalibro_configuration
    echoed = @port.request(:echo_configuration, {:configuration => configuration.to_hash})[:configuration]
    configuration.name = "echo " + configuration.name
    assert_equal configuration, Kalibro::Entities::Configuration.from_hash(echoed)
  end
  
end