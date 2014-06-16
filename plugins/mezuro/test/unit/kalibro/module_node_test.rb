require "test_helper"
require "#{Rails.root}/plugins/mezuro/test/fixtures/module_node_fixtures"

class ModuleNodeTest < ActiveSupport::TestCase

  def setup
    @hash = ModuleNodeFixtures.module_node_hash
    @node = ModuleNodeFixtures.module_node
  end

  should 'create module node from hash' do
    assert_equal( @node.child[0].module.name, Kalibro::ModuleNode.new(@hash).child[0].module.name)
  end

  should 'convert children hash to array of ModuleNode' do
    assert_equal @hash, @node.to_hash
  end
  
end
