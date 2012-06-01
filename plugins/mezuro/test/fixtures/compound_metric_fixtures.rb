class CompoundMetricFixtures

  def self.sc
    sc = Kalibro::Entities::CompoundMetric.new
    sc.description = 'Calculate the Structural Complexity of the Code'
    sc.name = 'Structural Complexity'
    sc.scope = 'CLASS'
    sc.script = 'return 42;'
    sc
  end

  def self.sc_hash
    {:name => 'Structural Complexity', :scope => 'CLASS', :script => 'return 42;', :description => 'Calculate the Structural Complexity of the Code'}
  end

end
