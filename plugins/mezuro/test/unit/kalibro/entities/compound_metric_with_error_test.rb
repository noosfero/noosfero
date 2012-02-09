require "test_helper"
class CompoundMetricWithErrorTest < ActiveSupport::TestCase
  
  def self.fixture
    fixture = Kalibro::Entities::CompoundMetricWithError.new
    fixture.metric = CompoundMetricTest.sc
    fixture.error = ErrorTest.fixture
    fixture
  end

  def self.fixture_hash
    {:metric => CompoundMetricTest.sc_hash,
     :error => ErrorTest.fixture_hash}
  end

  def setup
    @hash = self.class.fixture_hash
    @entity = self.class.fixture
  end

  should 'create error from hash' do
    assert_equal @entity, Kalibro::Entities::CompoundMetricWithError.from_hash(@hash)
  end

  should 'convert error to hash' do
    assert_equal @hash, @entity.to_hash
  end

end
