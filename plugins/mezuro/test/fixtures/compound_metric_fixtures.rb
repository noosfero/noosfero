class CompoundMetricFixtures

  def self.compound_metric
    Kalibro::CompoundMetric.new compound_metric_hash
  end

  def self.compound_metric_hash
    {:name => 'Structural Complexity', :scope => 'CLASS', :script => 'return 42;', :description => 'Calculate the Structural Complexity of the Code'}
  end

end
