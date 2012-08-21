class ModuleFixtures

  def self.module
    Kalibro::Module.new module_hash
  end

  def self.module_hash
    {
      :name => 'Qt-Calculator',
      :granularity => 'APPLICATION'
    }
  end
    
end
