require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/compound_metric_with_error_fixtures"

class CompoundMetricWithErrorTest < ActiveSupport::TestCase
  
  def setup
    @hash = CompoundMetricWithErrorFixtures.create_hash
    @entity = CompoundMetricWithErrorFixtures.create
  end

  should 'create error from hash' do
    assert_equal @entity, Kalibro::Entities::CompoundMetricWithError.from_hash(@hash)
  end

  should 'convert error to hash' do
    assert_equal @hash, @entity.to_hash
  end

end
