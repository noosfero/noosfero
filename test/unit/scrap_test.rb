require File.join(File.dirname(__FILE__), '..', 'test_helper')

class ScrapTest < ActiveSupport::TestCase

  def setup
    Person.delete_all
    Scrap.delete_all
  end

  should "have the content" do
    s = Scrap.new
    s.valid?
    assert s.errors.invalid?(:content)

    s.content = ''
    s.valid?
    assert s.errors.invalid?(:content)

    s.content = 'some content'
    s.valid?
    assert !s.errors.invalid?(:content)
  end

  should "have the sender" do
    s = Scrap.new
    s.valid?
    assert s.errors.invalid?(:sender_id)

    s.sender_id = 1
    s.valid?
    assert !s.errors.invalid?(:sender_id)
  end

  should "have the receiver" do
    s = Scrap.new
    s.valid?
    assert s.errors.invalid?(:receiver_id)

    s.receiver_id = 1
    s.valid?
    assert !s.errors.invalid?(:receiver_id)
  end

  should "be associated to Person as sender" do
    person = fast_create(Person)
    s = Scrap.new
    assert_nothing_raised do
      s.sender = person
    end
  end

  should "be associated to Person as receiver" do
    person = fast_create(Person)
    s = Scrap.new
    assert_nothing_raised do
      s.receiver = person
    end
  end

  should "be associated to Community as receiver" do
    community = fast_create(Community)
    s = Scrap.new
    assert_nothing_raised do
      s.receiver = community
    end
  end

  should "collect all scraps sent and received of a person" do
    person = fast_create(Person)
    s1 = fast_create(Scrap, :sender_id => person.id)
    assert_equal [s1], Scrap.all_scraps(person)
    s2 = fast_create(Scrap, :sender_id => person.id)
    assert_equal [s1,s2], Scrap.all_scraps(person)
    s3 = fast_create(Scrap, :receiver_id => person.id)
    assert_equal [s1,s2,s3], Scrap.all_scraps(person)
  end

  should "collect all scraps sent and received of a community" do
    community = fast_create(Community)
    person = fast_create(Person)
    s1 = fast_create(Scrap, :sender_id => person.id)
    assert_equal [], Scrap.all_scraps(community)
    s2 = fast_create(Scrap, :receiver_id => community.id, :sender_id => person.id)
    assert_equal [s2], Scrap.all_scraps(community)
    s3 = fast_create(Scrap, :receiver_id => community.id)
    assert_equal [s2,s3], Scrap.all_scraps(community)
  end

  should "create the leave_scrap action tracker verb on scrap creation of one user to another" do
    p1 = fast_create(Person)
    p2 = fast_create(Person)
    s = Scrap.new
    s.sender= p1
    s.receiver= p2
    s.content = 'some content'
    s.save!
    ta = ActionTracker::Record.last
    assert_equal s.content, ta.params['content']
    assert_equal s.sender.name, ta.params['sender_name']
    assert_equal s.receiver.name, ta.params['receiver_name']
    assert_equal s.receiver.url, ta.params['receiver_url']
    assert_equal 'leave_scrap', ta.verb
    assert_equal p1, ta.user
  end

  should "create the leave_scrap action tracker verb on scrap creation of one user to community" do
    p = fast_create(Person)
    c = fast_create(Community)
    s = Scrap.new
    s.sender= p
    s.receiver= c
    s.content = 'some content'
    s.save!
    ta = ActionTracker::Record.last
    assert_equal s.content, ta.params['content']
    assert_equal s.sender.name, ta.params['sender_name']
    assert_equal s.receiver.name, ta.params['receiver_name']
    assert_equal s.receiver.url, ta.params['receiver_url']
    assert_equal 'leave_scrap', ta.verb
    assert_equal p, ta.user
    assert_equal c, ta.target
  end

  should "notify leave_scrap action tracker verb to friends and itself" do
    p1 = fast_create(Person)
    p2 = fast_create(Person)
    p1.add_friend(p2)
    ActionTrackerNotification.delete_all
    Delayed::Job.delete_all
    s = Scrap.new
    s.sender= p1
    s.receiver= p2
    s.content = 'some content'
    s.save!
    process_delayed_job_queue
    assert_equal 2, ActionTrackerNotification.count
    ActionTrackerNotification.all.map{|a|a.profile}.map do |profile|
      assert [p1,p2].include?(profile)
    end
  end

  should "notify leave_scrap action tracker verb to members of the communities and the community itself" do
    p = fast_create(Person)
    c = fast_create(Community)
    c.add_member(p)
    ActionTrackerNotification.delete_all
    Delayed::Job.delete_all
    s = Scrap.new
    s.sender= p
    s.receiver= c
    s.content = 'some content'
    s.save!
    process_delayed_job_queue
    assert_equal 2, ActionTrackerNotification.count
    ActionTrackerNotification.all.map{|a|a.profile}.map do |profile|
      assert [p,c].include?(profile)
    end
  end

  should "create the leave_scrap_to_self action tracker verb on scrap creation of one user to itself" do
    p = fast_create(Person)
    s = Scrap.new
    s.sender= p
    s.receiver= p
    s.content = 'some content'
    s.save!
    ta = ActionTracker::Record.last
    assert_equal s.content, ta.params['content']
    assert_equal s.sender.name, ta.params['sender_name']
    assert_equal 'leave_scrap_to_self', ta.verb
    assert_equal p, ta.user
  end

  should "notify leave_scrap_to_self action tracker verb to friends and itself" do
    p1 = fast_create(Person)
    p2 = fast_create(Person)
    p1.add_friend(p2)
    ActionTrackerNotification.delete_all
    Delayed::Job.delete_all
    s = Scrap.new
    s.sender= p1
    s.receiver= p1
    s.content = 'some content'
    s.save!
    process_delayed_job_queue
    assert_equal 2, ActionTrackerNotification.count
    ActionTrackerNotification.all.map{|a|a.profile}.map do |profile|
      assert [p1,p2].include?(profile)
    end
  end

  should "get replies of a scrap" do
    s = fast_create(Scrap)
    s1 = fast_create(Scrap, :scrap_id => s.id)
    s2 = fast_create(Scrap)
    s3 = fast_create(Scrap, :scrap_id => s.id)
    assert_equal [s1,s3], s.replies
  end

  should "get only replies scrap" do
    s0 = fast_create(Scrap)
    s1 = fast_create(Scrap, :scrap_id => s0.id)
    s2 = fast_create(Scrap)
    s3 = fast_create(Scrap, :scrap_id => s0.id)
    assert_equal [s0,s2], Scrap.not_replies
  end

  should "remove the replies is the root is removed" do
    s = fast_create(Scrap)
    s1 = fast_create(Scrap, :scrap_id => s.id)
    s2 = fast_create(Scrap, :scrap_id => s.id)
    assert_equal [s1,s2], s.replies
    assert_equal 3, Scrap.count
    s.destroy
    assert_equal 0, Scrap.count
  end

  should "update the scrap on reply creation" do
    person = fast_create(Person)
    s = fast_create(Scrap, :updated_at => DateTime.parse('2010-01-01'))
    assert_equal DateTime.parse('2010-01-01'), s.updated_at.strftime('%Y-%m-%d')
    s1 = Scrap.create!(:content => 'some content', :sender => person, :receiver => person, :scrap_id => s.id)
    s.reload
    assert_not_equal DateTime.parse('2010-01-01'), s.updated_at.strftime('%Y-%m-%d')
  end

  should "have the root defined" do
    s = fast_create(Scrap)
    s1 = fast_create(Scrap, :scrap_id => s.id)
    s2 = fast_create(Scrap, :scrap_id => s.id)
    assert_equal s, s1.root
    assert_equal s, s2.root
  end

  should 'strip all html tags' do
    s, r = fast_create(Person), fast_create(Person)
    s = Scrap.new :sender => s, :receiver => r, :content => "<p>Test <b>Rails</b></p>"
    assert_equal "Test Rails", s.strip_all_html_tags
  end

  should 'strip html before save' do
    s, r = fast_create(Person), fast_create(Person)
    s = Scrap.new :sender => s, :receiver => r, :content => "<p>Test <b>Rails</b></p>"
    s.save!
    assert_equal "Test Rails", s.reload.content
  end

  should 'strip html before validate' do
    s, r = fast_create(Person), fast_create(Person)
    s = Scrap.new :sender => s, :receiver => r, :content => "<p><b></b></p>"
    assert !s.valid?
    s.content = "<p>Test</p>"
    assert s.valid?
  end

  should 'the action_tracker_target be the community when the scraps has the community as receiver' do
    scrap = Scrap.new
    assert_equal scrap, scrap.action_tracker_target
    
    community = fast_create(Community)
    scrap.receiver = community
    assert_equal community, scrap.action_tracker_target
  end

  should 'scrap wall url be the root scrap receiver url if it is a reply' do
    p1, p2 = fast_create(Person), fast_create(Person)
    r = Scrap.create! :sender => p1, :receiver => p2, :content => "Hello!"
    s = Scrap.new :sender => p2, :receiver => p1, :content => "Hi!"
    r.replies << s; s.reload
    assert_equal s.scrap_wall_url, s.root.receiver.wall_url
  end

  should 'scrap wall url be the scrap receiver url if it is not a reply' do
    p1, p2 = fast_create(Person), fast_create(Person)
    s = Scrap.create! :sender => p1, :receiver => p2, :content => "Hello!"
    assert_equal s.scrap_wall_url, s.receiver.wall_url
  end

end
