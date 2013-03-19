require 'test_helper'

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/metric_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/metric_configuration_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/configuration_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/range_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/reading_fixtures"

class MezuroPluginRangeControllerTest < ActionController::TestCase

  def setup
    @controller = MezuroPluginRangeController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    @profile = fast_create(Profile)

    @metric_configuration = MetricConfigurationFixtures.amloc_metric_configuration
    @metric_configuration_hash = MetricConfigurationFixtures.amloc_metric_configuration_hash
    @configuration = ConfigurationFixtures.configuration

    @content = MezuroPlugin::ConfigurationContent.new(:profile => @profile, :name => @configuration.name, :configuration_id => 42)
    @content.expects(:send_configuration_to_service).returns(nil)
    @content.expects(:validate_configuration_name).returns(true)
    @content.stubs(:solr_save)
    @content.save

    @created_range = RangeFixtures.created_range
    @range = RangeFixtures.range
    @created_range_hash = RangeFixtures.created_range_hash 
    @range_hash = RangeFixtures.range_hash

    @reading = ReadingFixtures.reading
  end

  should 'set correct attributes to create a new range' do
    Kalibro::Reading.expects(:readings_of).with(@metric_configuration.reading_group_id).returns([@reading])
    get :new, :profile => @profile.identifier, :id => @content.id, :metric_configuration_id => @metric_configuration.id, :reading_group_id => @metric_configuration.reading_group_id, :compound => @metric_configuration.metric.compound
    assert_equal @content.id, assigns(:content_id)
    assert_equal @metric_configuration.id, assigns(:metric_configuration_id)
    assert_equal [[@reading.label,@reading.id]], assigns(:reading_labels_and_ids)
    assert_equal @metric_configuration.reading_group_id, assigns(:reading_group_id)
    assert_equal @metric_configuration.metric.compound, assigns(:compound)
    assert_response :success
  end

  should 'set correct attributes to edit a range' do
    Kalibro::Reading.expects(:readings_of).with(@metric_configuration.reading_group_id).returns([@reading])
    Kalibro::Range.expects(:ranges_of).with(@metric_configuration.id).returns([@range])
    get :edit, :profile => @profile.identifier, :id => @content.id, :metric_configuration_id => @metric_configuration.id, :range_id => @range.id, :reading_group_id => @metric_configuration.reading_group_id
    assert_equal @content.id, assigns(:content_id)
    assert_equal @metric_configuration.id, assigns(:metric_configuration_id)
    assert_equal [[@reading.label,@reading.id]], assigns(:reading_labels_and_ids)
    assert_equal @range, assigns(:range)
    assert_response :success
  end

  should 'test create instance range' do
    Kalibro::Range.expects(:request).with(:save_range, {
        :metric_configuration_id => @metric_configuration.id,
        :range => @created_range.to_hash}).returns(:range_id => @range.id)
    Kalibro::Reading.expects(:find).with(@created_range.reading_id).returns(@reading)
    get :create, :profile => @profile.identifier, :range => @created_range_hash, :metric_configuration_id => @metric_configuration.id, :reading_group_id => @metric_configuration.reading_group_id, :compound => @metric_configuration.metric.compound
    assert_equal @range.id, assigns(:range).id
    assert_equal @metric_configuration.reading_group_id, assigns(:reading_group_id)
    assert_equal @metric_configuration.metric.compound, assigns(:compound)
    assert_response :success
  end

  should 'test update range' do
    Kalibro::Range.expects(:request).with(:save_range, {
        :metric_configuration_id => @metric_configuration.id,
        :range => @range.to_hash}).returns(:range_id => @range.id)
    get :update, :profile => @profile.identifier, :range => @range_hash, :metric_configuration_id => @metric_configuration.id
    assert_equal @range.id, assigns(:range).id
    assert_response :success
  end

  should 'test remove range in native metric configuration' do
    Kalibro::Range.expects(:new).with({:id => @range.id}).returns(@range)
    @range.expects(:destroy).with().returns()
    get :remove, :profile => @profile.identifier, :id => @content.id, :metric_configuration_id => @metric_configuration.id, :range_id => @range.id, :compound => false
     assert_response :redirect
  end
end
