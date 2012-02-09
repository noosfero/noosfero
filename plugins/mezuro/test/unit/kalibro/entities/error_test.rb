require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/error_fixtures"

class ErrorTest < ActiveSupport::TestCase

  def setup
    @hash = ErrorFixtures.create_hash
    @error = ErrorFixtures.create
  end

  should 'create error from hash' do
    assert_equal @error, Kalibro::Entities::Error.from_hash(@hash)
  end

  should 'convert error to hash' do
    assert_equal @hash, @error.to_hash
  end

end