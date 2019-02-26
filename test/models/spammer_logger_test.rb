require_relative "../test_helper"

class SpammerLoggerTest < ActiveSupport::TestCase
  should 'log the spammer ip' do
    SpammerLogger.log('192.168.0.1')
    log = File.open('log/test_spammers.log')
    assert_match 'IP: 192.168.0.1', log.read
  end

  should 'log the spammer ip with comment associated' do
    comment = fast_create(Comment)
    SpammerLogger.log('192.168.0.1', comment)
    log = File.open('log/test_spammers.log')
    assert_match "Comment-id: #{comment.id} IP: 192.168.0.1", log.read
  end
end
