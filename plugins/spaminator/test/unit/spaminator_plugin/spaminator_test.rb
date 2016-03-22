require 'test_helper'

class SpaminatorPlugin::SpaminatorTest < ActiveSupport::TestCase

  def setup
    @environment = Environment.default
    @spaminator = SpaminatorPlugin::Spaminator.new(@environment)
    @spaminator.stubs(:puts)
    @settings = Noosfero::Plugin::Settings.new(@environment, SpaminatorPlugin)
    @now = Time.now
    Time.stubs(:now).returns(@now)
  end

  attr_accessor :spaminator, :environment, :settings, :now

#  should 'search everything in the first run' do
#    assert_equal(['profiles.environment_id = ?',99], spaminator.send(:conditions, nil))
#  end
#
#  should 'search using recorded last date' do
#    settings.last_run = now
#    assert_equal(['profiles.environment_id = ? AND table.created_at > ?', 99, now], spaminator.send(:conditions, 'table'))
#  end

  should 'record time of last run in environment' do
    spaminator.expects(:process_all_comments)
    spaminator.expects(:process_all_people)
    environment.stubs(:save!)
    spaminator.run
    assert_equal now, settings.last_run
  end

  should 'process only comments from the environment and that are not spams' do
    profile = fast_create(Profile, :environment_id => environment)
    another_profile = fast_create(Profile, :environment_id => fast_create(Environment))
    source = fast_create(Article, :profile_id => profile)
    another_source = fast_create(Article, :profile_id => another_profile)
    c1 = fast_create(Comment, :source_id => source, :source_type => source.class.to_s)
    c2 = fast_create(Comment, :source_id => source, :source_type => source.class.to_s)
    c3 = fast_create(Comment, :source_id => source, :source_type => source.class.to_s, :spam => true)
    c4 = fast_create(Comment, :source_id => another_source, :source_type => another_source.class.to_s)

    spaminator.expects(:process_comment).with(c1)
    spaminator.expects(:process_comment).with(c2)
    spaminator.expects(:process_comment).with(c3).never
    spaminator.expects(:process_comment).with(c4).never

    spaminator.send :process_all_comments
    assert_equal 2, report.processed_comments
  end

  should 'process only people from the environment and that are not abusers' do
    Person.delete_all
    p1 = fast_create(Person)
    p2 = fast_create(Person)
    p3 = fast_create(Person, :environment_id => fast_create(Environment))
    p4 = create_user('spammer').person
    spaminator.send(:mark_as_spammer, p4)

    spaminator.expects(:process_person_by_comments).with(p1)
    spaminator.expects(:process_person_by_comments).with(p2)
    spaminator.expects(:process_person_by_comments).with(p3).never
    spaminator.expects(:process_person_by_comments).with(p4).never

    spaminator.send :process_all_people
    assert_equal 2, report.processed_people
  end

  should 'process comment' do
    profile = fast_create(Profile)
    source = fast_create(Article, :profile_id => profile)
    comment = fast_create(Comment, :source_id => source, :source_type => source.class.to_s)
    Comment.any_instance.stubs(:check_for_spam)

    spaminator.send(:process_comment, comment)
    assert_equal 0, report.spams_by_content

    Comment.any_instance.stubs(:spam).returns(true)
    spaminator.send(:process_comment, comment)
    assert_equal 1, report.spams_by_content
  end

  should 'process person by comments' do
    person = create_user('spammer').person
    fast_create(Comment, :author_id => person, :spam => true)
    fast_create(Comment, :author_id => person, :spam => true)

    spaminator.send(:process_person_by_comments, person)
    assert_equal 0, report.spammers_by_comments
    refute person.abuser?

    fast_create(Comment, :author_id => person, :spam => true)
    spaminator.send(:process_person_by_comments, person)
    assert person.abuser?
    assert_equal 1, report.spammers_by_comments
  end

  should 'process person by network' do
    user   = User.current = create_user 'spammer'
    person = user.person
    person.created_at = Time.now - 2.months
    person.save!
    c1 = fast_create(Community)
    c2 = fast_create(Community)
    c1.add_member(person)
    c2.add_member(person)
    fast_create(Comment, :author_id => person)
    fast_create(Comment, :author_id => person)

    spaminator.send(:process_person_by_no_network, person)
    refute person.abuser?
    assert_equal 0, report.spammers_by_no_network
    assert_equal 0, report.spams_by_no_network
    assert person.visible

    c1.remove_member(person)
    spaminator.send(:process_person_by_no_network, person)
    refute person.abuser?
    assert_equal 1, report.spammers_by_no_network
    assert_equal 2, report.spams_by_no_network
    refute person.visible
  end

  should 'mark person as spammer' do
    person = create_user('spammer').person
    assert_difference 'AbuseComplaint.finished.count', 1 do
      spaminator.send(:mark_as_spammer, person)
    end
    person.reload
    refute person.visible
  end

  should 'send email notification after disabling person' do
    person = create_user('spammer').person
    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      spaminator.send(:disable_person, person)
      process_delayed_job_queue
    end
  end

  should 'not send email notification if person was not disabled' do
    person = create_user('spammer').person
    person.expects(:disable).returns(false)
    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      spaminator.send(:disable_person, person)
      process_delayed_job_queue
    end
  end

  private

  def report
    spaminator.instance_variable_get('@report')
  end

end
