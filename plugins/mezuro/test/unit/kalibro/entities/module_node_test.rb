require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/module_node_fixtures"

class ModuleNodeTest < ActiveSupport::TestCase

  def setup
    @hash = ModuleNodeFixtures.qt_calculator_tree_hash
    @node = ModuleNodeFixtures.qt_calculator_tree
  end

  should 'create module node from hash' do
    assert_equal @node, Kalibro::Entities::ModuleNode.from_hash(@hash)
  end

  should 'convert children hash to array of ModuleNode' do
    assert_equal @hash, @node.to_hash
  end
  
end