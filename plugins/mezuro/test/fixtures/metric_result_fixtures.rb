class MetricResultFixtures

  def self.amloc_result
    result = Kalibro::Entities::MetricResult.new
    result.metric = NativeMetricFixtures.amloc
    result.value = 0.0
    result.descendent_results = [40.0, 42.0]
    result.range = RangeFixtures.amloc_excellent
    result
  end

  def self.sc_result
    result = Kalibro::Entities::MetricResult.new
    result.metric = CompoundMetricFixtures.sc
    result.value = 1.0
    result.descendent_results = [2.0, 42.0]
    result
  end

  def self.amloc_result_hash
    {:metric => NativeMetricFixtures.amloc_hash, :value => 0.0, :descendent_result => [40.0, 42.0],
      :range => RangeFixtures.amloc_excellent_hash}
  end

  def self.sc_result_hash
    {:metric => CompoundMetricFixtures.sc_hash, :value => 1.0, :descendent_result => [2.0, 42.0]}
  end

end
