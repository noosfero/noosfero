require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/process_time_fixtures"

class ProcessTimeTest < ActiveSupport::TestCase

  def setup
    @hash = ProcessTimeFixtures.process_time_hash
    @process_time = ProcessTimeFixtures.process_time
  end

  should 'create process time from hash' do
    assert_equal @hash[:state], Kalibro::ProcessTime.new(@hash).state
    assert_equal @hash[:time].to_i, Kalibro::ProcessTime.new(@hash).time
  end

  should 'convert process time to hash' do
    assert_equal @hash, @process_time.to_hash
  end

  should 'get time as an integer' do
    assert_equal 1.class, @process_time.time.class
  end

end
