require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/base_tool_fixtures"

class BaseToolTest < ActiveSupport::TestCase

  def setup
    @hash = BaseToolFixtures.analizo_hash
    @base_tool = BaseToolFixtures.analizo
  end

  should 'create base tool from hash' do
    assert_equal @base_tool, Kalibro::Entities::BaseTool.from_hash(@hash)
  end

  should 'convert base tool to hash' do
    assert_equal @hash, @base_tool.to_hash
  end

end