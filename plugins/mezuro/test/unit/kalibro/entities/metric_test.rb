require "test_helper"
class MetricTest < ActiveSupport::TestCase
  
  def setup
    name = 'MetricTest metric'
    scope = 'METHOD'
    description = 'Metric created for testing'
    @hash = {:name => name, :scope => scope, :description => description}
    @metric = Kalibro::Entities::Metric.new
    @metric.name = name
    @metric.scope = scope
    @metric.description = description
  end

  should 'create metric from hash' do
    assert_equal @metric, Kalibro::Entities::Metric.from_hash(@hash)
  end

  should 'convert metric to hash' do
    assert_equal @hash, @metric.to_hash
  end

end