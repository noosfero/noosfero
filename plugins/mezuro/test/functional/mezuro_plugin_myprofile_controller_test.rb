require 'test_helper'

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/error_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/base_tool_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/native_metric_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/metric_configuration_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/configuration_fixtures"

class MezuroPluginMyprofileControllerTest < ActionController::TestCase

  def setup
    @controller = MezuroPluginMyprofileController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    @profile = fast_create(Community)

    @base_tool = BaseToolFixtures.base_tool
    @base_tool_hash = BaseToolFixtures.base_tool_hash
    @metric = NativeMetricFixtures.amloc
    @metric_configuration = MetricConfigurationFixtures.amloc_metric_configuration
    @metric_configuration_hash = MetricConfigurationFixtures.amloc_metric_configuration_hash
    @compound_metric_configuration = MetricConfigurationFixtures.sc_metric_configuration
    @compound_metric_configuration_hash = MetricConfigurationFixtures.sc_metric_configuration_hash
    @configuration = ConfigurationFixtures.configuration
    @configuration_hash = ConfigurationFixtures.configuration_hash

    Kalibro::Configuration.expects(:all_names).returns([])
    @content = MezuroPlugin::ConfigurationContent.new(:profile => @profile, :name => @configuration.name)
    @content.expects(:send_kalibro_configuration_to_service).returns(nil)
    @content.stubs(:solr_save)
    @content.save

    @native_hash = @metric_configuration.to_hash.merge({:configuration_name => @metric_configuration.configuration_name})
    @native_hash.delete :attributes!    
    @compound_hash = @compound_metric_configuration.to_hash.merge({:configuration_name => @compound_metric_configuration.configuration_name})
    @compound_hash.delete :attributes!
  end

  should 'test choose base tool' do
    Kalibro::BaseTool.expects(:request).with("BaseTool", :get_base_tool_names).returns({:base_tool_name => @base_tool.name})
    get :choose_base_tool, :profile => @profile.identifier, :id => @content.id
    assert_equal [@base_tool.name], assigns(:base_tools)
    assert_equal @content, assigns(:configuration_content)
    assert_response 200
  end

  should 'test choose metric' do
    Kalibro::BaseTool.expects(:request).with("BaseTool", :get_base_tool, {:base_tool_name => @base_tool.name}).returns({:base_tool => @base_tool_hash})
    get :choose_metric, :profile => @profile.identifier, :id => @content.id, :base_tool => @base_tool.name
    assert_equal @content, assigns(:configuration_content)
    assert_equal @base_tool.name, assigns(:base_tool)
    assert_equal @base_tool.supported_metric[0].name, assigns(:supported_metrics)[0].name
    assert_response 200
  end

end
