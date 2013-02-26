class MetricFixtures

  def self.compound_metric
    Kalibro::Metric.new compound_metric_hash
  end

  def self.compound_metric_hash
    {:name => 'Structural Complexity', :compound => "true", :scope => 'CLASS', :script => 'return 42;', :description => 'Calculate the Structural Complexity of the Code'}
  end

  def self.total_cof
    Kalibro::Metric.new total_cof_hash
  end

  def self.total_cof_hash
    {:name => 'Total Coupling Factor', :compound => "false", :scope => 'SOFTWARE', :language => ['JAVA']}
  end

  def self.amloc
    Kalibro::Metric.new amloc_hash
  end

  def self.amloc_hash
    {:name => 'Average Method LOC', :compound => "false", :scope => 'CLASS', :language => ['JAVA']}
  end

end
