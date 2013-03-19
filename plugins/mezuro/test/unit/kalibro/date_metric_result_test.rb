require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/date_metric_result_fixtures"

class DateMetricResultTest < ActiveSupport::TestCase

  def setup
    @hash = DateMetricResultFixtures.date_metric_result_hash
    @date_metric_result = DateMetricResultFixtures.date_metric_result
  end

  should 'create date_metric_result from hash' do
    assert_equal @hash[:metric_result][:id].to_i, Kalibro::DateMetricResult.new(@hash).metric_result.id
  end

  should 'convert date_metric_result to hash' do
    assert_equal @hash, @date_metric_result.to_hash
  end

end
