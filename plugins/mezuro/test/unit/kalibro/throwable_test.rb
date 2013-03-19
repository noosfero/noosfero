require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/throwable_fixtures"

class ThrowableTest < ActiveSupport::TestCase

  def setup
    @hash = ThrowableFixtures.throwable_hash
    @throwable = ThrowableFixtures.throwable
  end

  should 'create throwable from hash' do
    assert_equal @hash[:message], Kalibro::Throwable.new(@hash).message
  end

  should 'convert throwable to hash' do
    assert_equal @hash, @throwable.to_hash
  end

end
