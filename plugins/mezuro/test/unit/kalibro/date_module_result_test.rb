require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/date_module_result_fixtures"

class DateModuleResultTest < ActiveSupport::TestCase

  def setup
    @hash = DateModuleResultFixtures.date_module_result_hash
    @date_module_result = DateModuleResultFixtures.date_module_result
  end

  should 'create date_module_result from hash' do
    assert_equal @hash[:module_result][:id].to_i, Kalibro::DateModuleResult.new(@hash).module_result.id
  end

  should 'convert date_module_result to hash' do
    assert_equal @hash, @date_module_result.to_hash
  end

end
