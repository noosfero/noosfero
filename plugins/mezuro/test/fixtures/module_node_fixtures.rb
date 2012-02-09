class ModuleNodeFixtures

  def self.qt_calculator_tree
    node = Kalibro::Entities::ModuleNode.new
    node.module = ModuleFixtures.qt_calculator
    node.children = [new_node('Dialog', 'CLASS'), new_node('main', 'CLASS')]
    node
  end

  def self.qt_calculator_tree_hash
    {:module => ModuleFixtures.qt_calculator_hash,
      :child => [
        {:module => {:name => 'Dialog', :granularity => 'CLASS'}},
        {:module => {:name => 'main', :granularity => 'CLASS'}}
      ]
    }
  end

  private

  def self.new_node(name, granularity)
    the_module = Kalibro::Entities::Module.new
    the_module.name = name
    the_module.granularity = granularity
    node = Kalibro::Entities::ModuleNode.new
    node.module = the_module
    node
  end
    
end
