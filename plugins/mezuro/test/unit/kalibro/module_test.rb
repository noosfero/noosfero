require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/module_fixtures"

class ModuleTest < ActiveSupport::TestCase

  def setup
    @hash = ModuleFixtures.module_hash
    @module = ModuleFixtures.module
  end

  should 'create module from hash' do
    assert_equal @hash[:name], Kalibro::Module.new(@hash).name
  end
  
  should 'convert module to hash' do
    assert_equal @hash, @module.to_hash
  end

  should 'list ancestor names' do
    @module.name = "org.kalibro.core"
    assert_equal ["org", "org.kalibro", "org.kalibro.core"], @module.ancestor_names
  end

  should 'list ancestor with one name' do
    @module.name = "org"
    assert_equal ["org"], @module.ancestor_names
  end
 
end
