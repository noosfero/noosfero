class ModuleFixtures

  def self.qt_calculator
    entity = Kalibro::Entities::Module.new
    entity.name = 'Qt-Calculator'
    entity.granularity = 'APPLICATION'
    entity
  end

  def self.qt_calculator_hash
    {:name => 'Qt-Calculator', :granularity => 'APPLICATION'}
  end
    
end
