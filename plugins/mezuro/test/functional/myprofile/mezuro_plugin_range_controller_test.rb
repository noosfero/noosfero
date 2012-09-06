require 'test_helper'

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/error_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/base_tool_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/native_metric_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/metric_configuration_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/configuration_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/range_fixtures"

class MezuroPluginRangeControllerTest < ActionController::TestCase

  def setup
    @controller = MezuroPluginRangeController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    @profile = fast_create(Community)

    @metric = NativeMetricFixtures.amloc
    @metric_configuration = MetricConfigurationFixtures.amloc_metric_configuration
    @metric_configuration_hash = MetricConfigurationFixtures.amloc_metric_configuration_hash
    @configuration = ConfigurationFixtures.configuration

    Kalibro::Configuration.expects(:all_names).returns([])
    @content = MezuroPlugin::ConfigurationContent.new(:profile => @profile, :name => @configuration.name)
    @content.expects(:send_kalibro_configuration_to_service).returns(nil)
    @content.stubs(:solr_save)
    @content.save

    @range = RangeFixtures.range_excellent
    @range_hash = RangeFixtures.range_excellent_hash
  end
  should 'test new range' do
    get :new_range, :profile => @profile.identifier, :id => @content.id, :metric_name => @metric.name
    assert_equal @content, assigns(:configuration_content)
    assert_equal @metric.name, assigns(:metric_name)
    assert_response 200
  end

  should 'test edit range' do
    Kalibro::MetricConfiguration.expects(:request).with("MetricConfiguration", :get_metric_configuration, {
      :configuration_name => @content.name,
      :metric_name => @metric.name}).returns({:metric_configuration => @metric_configuration_hash})
    get :edit_range, :profile => @profile.identifier, :id => @content.id, :metric_name => @metric.name, :beginning_id => @range.beginning
    assert_equal @content, assigns(:configuration_content)
    assert_equal @metric.name, assigns(:metric_name)
    assert_equal @range.beginning, assigns(:beginning_id)
    assert_equal @range.end, assigns(:range).end
    assert_response 200
  end

  should 'test create instance range' do
    metric_configuration = @metric_configuration
    metric_configuration.add_range(@range)
    Kalibro::MetricConfiguration.expects(:request).with("MetricConfiguration", :get_metric_configuration, {
      :configuration_name => @content.name,
      :metric_name => @metric.name}).returns({:metric_configuration => @metric_configuration_hash})
    Kalibro::MetricConfiguration.expects(:request).with("MetricConfiguration", :save_metric_configuration, {
        :metric_configuration => metric_configuration.to_hash,
        :configuration_name => metric_configuration.configuration_name})
    get :create_range, :profile => @profile.identifier, :range => @range_hash, :id => @content.id, :metric_name => @metric.name
    assert_equal @content, assigns(:configuration_content)
    assert_equal @range.end, assigns(:range).end
    assert_response 200
  end

  should 'test update range' do
    Kalibro::MetricConfiguration.expects(:request).with("MetricConfiguration", :get_metric_configuration, {
      :configuration_name => @content.name,
      :metric_name => @metric.name}).returns({:metric_configuration => @metric_configuration_hash})
    Kalibro::MetricConfiguration.expects(:request).with("MetricConfiguration", :save_metric_configuration, {
        :metric_configuration => @metric_configuration.to_hash,
        :configuration_name => @metric_configuration.configuration_name})
    get :update_range,
        :profile => @profile.identifier,
        :range => @range_hash,
        :id => @content.id,
        :metric_name => @metric.name,
        :beginning_id => @range.beginning
    assert_response 200
  end

  should 'test remove range' do
    metric_configuration = @metric_configuration
    metric_configuration.ranges.delete_if { |range| range.beginning == @range.beginning.to_f }
    Kalibro::MetricConfiguration.expects(:request).with("MetricConfiguration", :get_metric_configuration, {
      :configuration_name => @content.name,
      :metric_name => @metric.name}).returns({:metric_configuration => @metric_configuration_hash})
    Kalibro::MetricConfiguration.expects(:request).with("MetricConfiguration", :save_metric_configuration, {
        :metric_configuration => metric_configuration.to_hash,
        :configuration_name => metric_configuration.configuration_name})
    get :remove_range,
        :profile => @profile.identifier,
        :id => @content.id,
        :metric_name => @metric.name,
        :beginning_id => @range.beginning
     assert_response 302
  end
end
