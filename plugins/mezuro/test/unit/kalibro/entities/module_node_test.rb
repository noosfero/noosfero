require "test_helper"

class ModuleNodeTest < ActiveSupport::TestCase

  def self.qt_calculator_tree
    node = Kalibro::Entities::ModuleNode.new
    node.module = ModuleTest.qt_calculator
    node.children = [new_node('Dialog', 'CLASS'), new_node('main', 'CLASS')]
    node
  end

  def self.new_node(name, granularity)
    the_module = Kalibro::Entities::Module.new
    the_module.name = name
    the_module.granularity = granularity
    node = Kalibro::Entities::ModuleNode.new
    node.module = the_module
    node
  end

  def self.qt_calculator_tree_hash
    {:module => ModuleTest.qt_calculator_hash,
      :child => [
        {:module => {:name => 'Dialog', :granularity => 'CLASS'}},
        {:module => {:name => 'main', :granularity => 'CLASS'}}
      ]
    }
  end

  def setup
    @hash = self.class.qt_calculator_tree_hash
    @node = self.class.qt_calculator_tree
  end

  should 'create module node from hash' do
    assert_equal @node, Kalibro::Entities::ModuleNode.from_hash(@hash)
  end

  should 'convert children hash to array of ModuleNode' do
    assert_equal @hash, @node.to_hash
  end
  
end