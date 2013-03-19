require 'test_helper'

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/module_result_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/metric_result_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/date_metric_result_fixtures"
require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/date_module_result_fixtures"

class MezuroPluginModuleResultControllerTest < ActionController::TestCase

  def setup
    @controller = MezuroPluginModuleResultController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    @profile = fast_create(Community)

    @module_result_hash = ModuleResultFixtures.module_result_hash
    @metric_result_hash = MetricResultFixtures.native_metric_result_hash
    @date_metric_result_hash = DateMetricResultFixtures.date_metric_result_hash
    @date_module_result_hash = DateModuleResultFixtures.date_module_result_hash
  end

  should 'find module result on kalibro' do
    parent_module_result = ModuleResultFixtures.parent_module_result_hash
    Kalibro::ModuleResult.expects(:request).with(:get_module_result, { :module_result_id => @module_result_hash[:id].to_i }).
        returns({:module_result => @module_result_hash})
    Kalibro::MetricResult.expects(:request).with(:metric_results_of, { :module_result_id => @module_result_hash[:id].to_i }).
        returns({:metric_result => @metric_result_hash})
    Kalibro::ModuleResult.expects(:request).with(:get_module_result, { :module_result_id => @module_result_hash[:parent_id].to_i }).
        returns({:module_result => parent_module_result})
    Kalibro::ModuleResult.expects(:request).with(:children_of, {:module_result_id => @module_result_hash[:id].to_i}).
        returns({:module_result => nil})
    get :module_result, :profile => @profile.identifier, :module_result_id => @module_result_hash[:id]
    assert_equal @module_result_hash[:grade].to_f, assigns(:module_result).grade
    assert_equal @metric_result_hash[:value].to_f, assigns(:metric_results).first.value
    assert_response :success
    #TODO assert_select('h5', 'Metric results for: Qt-Calculator (APPLICATION)')
  end

  should 'get metric result history' do
    metric_name = @metric_result_hash[:configuration][:metric][:name]
    Kalibro::MetricResult.expects(:request).with(:history_of_metric, { :metric_name => metric_name, :module_result_id => @module_result_hash[:id].to_i }).
        returns({:date_metric_result => @date_metric_result_hash})
    get :metric_result_history, :profile => @profile.identifier, :module_result_id => @module_result_hash[:id], :metric_name => metric_name
    assert_equal DateTime.parse(@date_metric_result_hash[:date]), assigns(:history).first.date
    assert_response :success
    #TODO assert_select
  end

  should 'get module result history' do
    Kalibro::ModuleResult.expects(:request).with(:history_of_module, { :module_result_id => @module_result_hash[:id].to_i }).
        returns({:date_module_result => @date_module_result_hash})
    get :module_result_history, :profile => @profile.identifier, :module_result_id => @module_result_hash[:id]
    assert_equal DateTime.parse(@date_module_result_hash[:date]), assigns(:history).first.date
    assert_response :success
    #TODO assert_select
  end
  
end
