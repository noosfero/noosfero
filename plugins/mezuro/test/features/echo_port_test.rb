require "test_helper"

require "#{Rails.root}/plugins/mezuro/test/fixtures/base_tool_fixtures"
require "#{Rails.root}/plugins/mezuro/test/fixtures/configuration_fixtures"
require "#{Rails.root}/plugins/mezuro/test/fixtures/module_result_fixtures"
require "#{Rails.root}/plugins/mezuro/test/fixtures/project_result_fixtures"

class EchoPortTest < ActiveSupport::TestCase

  def setup
    @port = Kalibro::Client::Port.new('Echo')
    address = YAML.load_file("#{Rails.root}/plugins/mezuro/service.yaml")
    address['KalibroService'] = 'KalibroFake'
    @port.service_address=(address);
  end

  should 'echo base tool' do
    test BaseToolFixtures.analizo, 'BaseTool' do |base_tool|
      base_tool.name = "echo " + base_tool.name
    end
  end
  
  should 'echo configuration' do
    test ConfigurationFixtures.kalibro_configuration, 'Configuration' do |configuration|
      configuration.name = "echo " + configuration.name
    end
  end

  should 'echo metric configuration' do
    test_metric_configuration(MetricConfigurationFixtures.amloc_configuration)
    test_metric_configuration(MetricConfigurationFixtures.sc_configuration)
  end

  should 'echo module result' do
    test ModuleResultFixtures.create, 'ModuleResult' do |module_result|
      module_result.module.name = "echo." + module_result.module.name
    end
  end

  should 'echo project' do
    test(ProjectFixtures.qt_calculator, 'Project') do |project|
      project.name = "echo " + project.name
    end
  end

  should 'echo project result' do
    test(ProjectResultFixtures.qt_calculator, 'ProjectResult') do |project_result|
      project_result.project.name = "echo " + project_result.project.name
    end
  end

  should 'echo raw project' do
    project = ProjectFixtures.qt_calculator
    echoed = @port.request(:echo_raw_project, {:project => project.to_hash})[:project]
    project.name = "echo " + project.name
    project.state = nil
    project.error = nil
    assert_equal project, Kalibro::Entities::Project.from_hash(echoed)
  end

  should 'work with enums' do
    test_granularity("METHOD", "CLASS")
    test_granularity("CLASS", "PACKAGE")
    test_granularity("PACKAGE", "PACKAGE")
    test_granularity("APPLICATION", "APPLICATION")
  end

  private
  
  def test_metric_configuration(fixture)
    test fixture, 'MetricConfiguration' do |metric_configuration|
      metric_configuration.code = "echo_" + metric_configuration.code
    end
  end

  def test(fixture, entity_name)
    entity_symbol = entity_name.underscore.to_sym
    request_body = {entity_symbol => fixture.to_hash}
    echoed = @port.request("echo_#{entity_symbol}".to_sym, request_body)[entity_symbol]
    yield fixture
    entity_class = "Kalibro::Entities::#{entity_name}".constantize
    assert_equal fixture, entity_class.from_hash(echoed)
  end

  def test_granularity(granularity, parent)
    body = {:granularity => granularity}
    assert_equal parent, @port.request(:infer_parent_granularity, body)[:parent_granularity]
  end

end
