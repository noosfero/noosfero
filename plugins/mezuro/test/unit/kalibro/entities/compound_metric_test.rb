require "test_helper"
class CompoundMetricTest < ActiveSupport::TestCase

  def self.sc
    sc = Kalibro::Entities::CompoundMetric.new
    sc.name = 'Structural Complexity'
    sc.scope = 'CLASS'
    sc.script = 'return cbo * lcom4;'
    sc
  end

  def self.sc_hash
    {:name => 'Structural Complexity', :scope => 'CLASS',
      :script => 'return cbo * lcom4;'}
  end
  
  def setup
    @hash = self.class.sc_hash
    @metric = self.class.sc
  end

  should 'create compound metric from hash' do
    assert_equal @metric, Kalibro::Entities::CompoundMetric.from_hash(@hash)
  end

  should 'convert compound metric to hash' do
    assert_equal @hash, @metric.to_hash
  end

end