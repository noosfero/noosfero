require "test_helper"

require "#{Rails.root}/plugins/mezuro/test/fixtures/error_fixtures"

class ErrorTest < ActiveSupport::TestCase

  def setup
    @hash = ErrorFixtures.error_hash
    @error = ErrorFixtures.error
  end

  should 'create error from hash' do
    assert_equal @hash[:message], Kalibro::Error.new(@hash).message
  end

  should 'convert error to hash' do
    assert_equal @hash, @error.to_hash
  end

end
