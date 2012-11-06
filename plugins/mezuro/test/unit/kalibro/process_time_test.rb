require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/process_time_fixtures"

class ProcessTimeTest < ActiveSupport::TestCase

  def setup
    @hash = ProcessTimeFixtures.process_time_hash
    @process_time = ProcessTimeFixtures.process_time
  end

  should 'create process time from hash' do
    assert_equal @hash[:state], Kalibro::ProcessTime.new(@hash).state
  end

  should 'convert process time to hash' do
    assert_equal @hash, @process_time.to_hash
  end

end
