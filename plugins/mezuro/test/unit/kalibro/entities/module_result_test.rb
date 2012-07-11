require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/module_result_fixtures"

class ModuleResultTest < ActiveSupport::TestCase

  def setup
    @hash = ModuleResultFixtures.module_result_hash
    @result = ModuleResultFixtures.module_result
  end

  should 'create module result from hash' do
    assert_equal @result, Kalibro::Entities::ModuleResult.from_hash(@hash)
  end

  should 'convert module result to hash' do
    assert_equal @hash, Kalibro::Entities::ModuleResult.to_hash(@result)
  end

end
