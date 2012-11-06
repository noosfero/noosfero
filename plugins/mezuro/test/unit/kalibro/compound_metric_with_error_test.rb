require "test_helper"

require "#{Rails.root}/plugins/mezuro/test/fixtures/compound_metric_with_error_fixtures"

class CompoundMetricWithErrorTest < ActiveSupport::TestCase
  
  def setup
    @hash = CompoundMetricWithErrorFixtures.compound_metric_with_error_hash
    @compound_metric_with_error = CompoundMetricWithErrorFixtures.compound_metric_with_error
  end

  should 'create error from hash' do
    assert_equal @hash[:error][:message], Kalibro::CompoundMetricWithError.new(@hash).error.message
  end

  should 'convert error to hash' do
    assert_equal @hash, @compound_metric_with_error.to_hash
  end

end
