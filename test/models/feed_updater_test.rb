require_relative "../test_helper"

class FeedUpdaterTest < ActiveSupport::TestCase

  should 'be running by default' do
    assert_equal true, FeedUpdater.new.running
  end

  should 'unset running when stopped' do
    updater = FeedUpdater.new
    updater.expects(:running=).with(false)
    updater.stop
  end

  should 'sleep in intervals of one second' do
    FeedUpdater.stubs(:daemon_sleep_interval).returns(30)
    updater = FeedUpdater.new
    updater.expects(:sleep).with(1).times(30)
    updater.wait
  end

  should 'not sleep when stopped' do
    FeedUpdater.stubs(:daemon_sleep_interval).returns(30)
    updater = FeedUpdater.new
    updater.stubs(:running).returns(true).then.returns(true).then.returns(false)
    updater.expects(:sleep).with(1).times(2)
    updater.wait
  end

  should 'process until it is stopped' do
    updater = FeedUpdater.new
    updater.stubs(:running).returns(true).then.returns(true).then.returns(false)
    updater.expects(:process_round).times(2)
    updater.expects(:wait).times(2)
    updater.run
  end

end
