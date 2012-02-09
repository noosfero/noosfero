class CompoundMetricFixtures

  def self.sc
    sc = Kalibro::Entities::CompoundMetric.new
    sc.name = 'Structural Complexity'
    sc.scope = 'CLASS'
    sc.script = 'return cbo * lcom4;'
    sc
  end

  def self.sc_hash
    {:name => 'Structural Complexity', :scope => 'CLASS', :script => 'return cbo * lcom4;'}
  end

end
