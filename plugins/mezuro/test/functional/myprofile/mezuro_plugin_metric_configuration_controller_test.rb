require 'test_helper'

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/base_tool_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/metric_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/metric_configuration_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/configuration_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/reading_group_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/range_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/reading_fixtures"

class MezuroPluginMetricConfigurationControllerTest < ActionController::TestCase

  def setup
    @controller = MezuroPluginMetricConfigurationController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    @profile = fast_create(Profile)

    @configuration = ConfigurationFixtures.configuration
    @created_configuration = ConfigurationFixtures.created_configuration
    @configuration_hash = ConfigurationFixtures.configuration_hash

    @configuration_content = MezuroPlugin::ConfigurationContent.new(:profile => @profile, :name => @configuration.name, :configuration_id => 42)
    @configuration_content.expects(:send_configuration_to_service).returns(nil)
    @configuration_content.expects(:validate_configuration_name).returns(true)
    @configuration_content.save

    @base_tool = BaseToolFixtures.base_tool
    @base_tool_hash = BaseToolFixtures.base_tool_hash

    @metric = MetricFixtures.amloc

    @reading_group = ReadingGroupFixtures.reading_group
    @range = RangeFixtures.range
    @reading = ReadingFixtures.reading

    @native_metric_configuration = MetricConfigurationFixtures.amloc_metric_configuration
    @native_metric_configuration_hash = MetricConfigurationFixtures.amloc_metric_configuration_hash
    @created_metric_configuration = MetricConfigurationFixtures.created_metric_configuration
    @compound_metric_configuration = MetricConfigurationFixtures.sc_metric_configuration
    @compound_metric_configuration_hash = MetricConfigurationFixtures.sc_metric_configuration_hash
  end

  should 'choose metric' do
    Kalibro::BaseTool.expects(:all).returns([@base_tool])
    get :choose_metric, :profile => @profile.identifier, :id => @configuration_content.id
    assert_equal @configuration_content, assigns(:configuration_content)
    assert_equal [@base_tool], assigns(:base_tools)
    assert_response :success
  end

  should 'initialize native' do
    Kalibro::BaseTool.expects(:find_by_name).with(@base_tool.name).returns(@base_tool)
    Kalibro::ReadingGroup.expects(:all).returns([@reading_group])
    get :new_native, :profile => @profile.identifier, :id => @configuration_content.id, :base_tool_name => @base_tool.name, :metric_name => @metric.name
    assert_equal @configuration_content, assigns(:configuration_content)
    assert_equal @metric.name, assigns(:metric).name
    assert_equal @base_tool.name, assigns(:metric_configuration).base_tool_name
    assert_equal [[@reading_group.name,@reading_group.id]], assigns(:reading_group_names_and_ids)
    assert_response :success
  end

  should 'edit native' do
    Kalibro::MetricConfiguration.expects(:metric_configurations_of).with(@configuration.id).returns([@native_metric_configuration])
    Kalibro::ReadingGroup.expects(:all).returns([@reading_group])
    Kalibro::Range.expects(:ranges_of).with(@native_metric_configuration.id).returns([@range])
    Kalibro::Reading.expects(:find).with(@range.reading_id).returns(@reading)    
    get :edit_native, :profile => @profile.identifier, :id => @configuration_content.id, :metric_configuration_id => @native_metric_configuration.id
    assert_equal @configuration_content, assigns(:configuration_content)
    assert_equal @native_metric_configuration.code, assigns(:metric_configuration).code
    assert_equal @native_metric_configuration.metric.name, assigns(:metric).name
    assert_equal [[@reading_group.name,@reading_group.id]], assigns(:reading_group_names_and_ids)
    assert_equal [@range], assigns(:ranges)
    assert_response :success
  end

  should 'initialize compound' do
    Kalibro::ReadingGroup.expects(:all).returns([@reading_group])
    Kalibro::MetricConfiguration.expects(:metric_configurations_of).with(@configuration_content.configuration_id).returns([@compound_metric_configuration])
    get :new_compound, :profile => @profile.identifier, :id => @configuration_content.id
    assert_equal @configuration_content, assigns(:configuration_content)
    assert_equal @compound_metric_configuration.code, assigns(:metric_configurations).first.code
    assert_equal [[@reading_group.name,@reading_group.id]], assigns(:reading_group_names_and_ids)
    assert_response :success
  end

  should 'edit compound' do
    Kalibro::MetricConfiguration.expects(:metric_configurations_of).with(@configuration.id).returns([@compound_metric_configuration])
    Kalibro::ReadingGroup.expects(:all).returns([@reading_group])
    Kalibro::Range.expects(:ranges_of).with(@compound_metric_configuration.id).returns([@range])
    Kalibro::Reading.expects(:find).with(@range.reading_id).returns(@reading)    
    get :edit_compound, :profile => @profile.identifier, :id => @configuration_content.id, :metric_configuration_id => @compound_metric_configuration.id
    assert_equal @configuration_content, assigns(:configuration_content)
    assert_equal @compound_metric_configuration.code, assigns(:metric_configuration).code
    assert_equal @compound_metric_configuration.metric.name, assigns(:metric).name
    assert_equal [@compound_metric_configuration], assigns(:metric_configurations)
    assert_equal [[@reading_group.name,@reading_group.id]], assigns(:reading_group_names_and_ids)
    assert_equal [@range], assigns(:ranges)
    assert_response :success
  end

  should 'create' do
    Kalibro::MetricConfiguration.expects(:create).returns(@compound_metric_configuration) #FIXME need .with(some_hash), should it mock the request?.
    get :create, :profile => @profile.identifier, :id => @configuration_content.id, :metric_configuration => @compound_metric_configuration_hash
    assert_response :redirect
  end

  should 'update' do
    Kalibro::MetricConfiguration.expects(:metric_configurations_of).with(@configuration_content.configuration_id).returns([@native_metric_configuration])
    @native_metric_configuration.expects(:update_attributes).returns(true) #FIXME need .with(some_hash), should it mock the request?.
    get :update, :profile => @profile.identifier, :id => @configuration_content.id, :metric_configuration => @native_metric_configuration_hash
    assert_equal @configuration_content, assigns(:configuration_content)
    assert_response :redirect
  end

  should 'remove' do
    Kalibro::MetricConfiguration.expects(:new).with({:id => @native_metric_configuration.id}).returns(@native_metric_configuration)
    @native_metric_configuration.expects(:destroy).returns()
    get :remove, :profile => @profile.identifier, :id => @configuration_content.id, :metric_configuration_id => @native_metric_configuration.id
    assert_response :redirect
  end

end
