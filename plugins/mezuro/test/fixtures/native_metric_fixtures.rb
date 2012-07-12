class NativeMetricFixtures

  def self.total_cof
    Kalibro::NativeMetric.new total_cof_hash
  end

  def self.total_cof_hash
    {:name => 'Total Coupling Factor', :scope => 'APPLICATION', :origin => 'Analizo', :language => ['JAVA']}
  end

  def self.amloc
    Kalibro::NativeMetric.new amloc_hash
  end

  def self.amloc_hash
    {:name => 'Average Method LOC', :scope => 'CLASS', :origin => 'Analizo', :language => ['JAVA']}
  end

end
