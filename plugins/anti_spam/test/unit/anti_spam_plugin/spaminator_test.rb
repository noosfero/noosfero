require 'test_helper'

class AntiSpamPluginSpaminatorTest < ActiveSupport::TestCase

  def setup
    @environment = Environment.new
    @environment.id = 99
    @spaminator = AntiSpamPlugin::Spaminator.new(@environment)
    @spaminator.stubs(:puts)
    @now = Time.now
    Time.stubs(:now).returns(@now)
  end

  should 'search everything in the first run' do
    assert_equal(['profiles.environment_id = ?',99], @spaminator.send(:conditions, nil))
  end

  should 'search using recorded last date' do
    @environment.settings[:spaminator_last_run] = @now
    assert_equal(['profiles.environment_id = ? AND table.created_at > ?', 99, @now], @spaminator.send(:conditions, 'table'))
  end

  should 'record time of last run in environment' do
    @spaminator.expects(:process_all_comments)
    @spaminator.expects(:process_all_people)
    @environment.stubs(:save!)
    @spaminator.run
    assert_equal @now, @environment.settings[:spaminator_last_run]
  end

  should 'find all comments' do
    @spaminator.stubs(:process_comment)
    @spaminator.send :process_all_comments
  end

  should 'find all people' do
    @spaminator.stubs(:process_person)
    @spaminator.send :process_all_people
  end

  should 'find all comments newer than a date' do
    @environment.settings[:spaminator_last_run] = Time.now - 1.month
    @spaminator.stubs(:process_comment)
    @spaminator.send :process_all_comments
  end

  should 'find all people newer than a date' do
    @environment.settings[:spaminator_last_run] = Time.now - 1.month
    @spaminator.stubs(:process_person)
    @spaminator.send :process_all_people
  end

end
