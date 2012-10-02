require 'test_helper'

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/base_tool_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/configuration_fixtures"

class MezuroPluginBaseToolControllerTest < ActionController::TestCase

  def setup
    @controller = MezuroPluginBaseToolController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    @profile = fast_create(Community)

    @base_tool = BaseToolFixtures.base_tool
    @base_tool_hash = BaseToolFixtures.base_tool_hash
    @configuration = ConfigurationFixtures.configuration

    Kalibro::Configuration.expects(:all_names).returns([])
    @content = MezuroPlugin::ConfigurationContent.new(:profile => @profile, :name => @configuration.name)
    @content.expects(:send_kalibro_configuration_to_service).returns(nil)
    @content.stubs(:solr_save)
    @content.save
  end

  should 'test choose metric' do
    Kalibro::BaseTool.expects(:request).with("BaseTool", :get_base_tool_names).returns({:base_tool_name => @base_tool.name})
    Kalibro::BaseTool.expects(:request).with("BaseTool", :get_base_tool, {:base_tool_name => @base_tool.name}).returns({:base_tool => @base_tool_hash})
    get :choose_metric, :profile => @profile.identifier, :id => @content.id
    assert_equal @base_tool.name, assigns(:base_tools).first.name
    assert_equal @content, assigns(:configuration_content)
    assert_response 200
  end

end
