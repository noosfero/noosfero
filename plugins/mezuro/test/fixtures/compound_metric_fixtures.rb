class CompoundMetricFixtures

  def self.sc
    sc = Kalibro::Entities::CompoundMetric.new
    sc.name = 'Structural Complexity'
    sc.scope = 'CLASS'
    sc.script = 'return 42;'
    sc
  end

  def self.sc_hash
    {:name => 'Structural Complexity', :scope => 'CLASS', :script => 'return 42;'}
  end

end
