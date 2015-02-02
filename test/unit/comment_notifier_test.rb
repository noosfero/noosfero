require_relative "../test_helper"

class CommentNotifierTest < ActiveSupport::TestCase
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  CHARSET = "utf-8"

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    @profile = create_user('content_owner').person
    @author = create_user('author').person
    @article = fast_create(Article, :name => 'Article test', :profile_id => @profile.id, :notify_comments => true)
  end

  should 'deliver mail after make an article comment' do
    assert_difference 'ActionMailer::Base.deliveries.size' do
      create_comment_and_notify(:author => @author, :title => 'test comment', :body => 'you suck!', :source => @article )
    end
  end

  should 'deliver mail to owner of article' do
    create_comment_and_notify(:author => @author, :title => 'test comment', :body => 'you suck!', :source => @article )
    sent = ActionMailer::Base.deliveries.first
    assert_equal [@profile.email], sent.to
  end

  should 'display author name in delivered mail' do
    create_comment_and_notify(:author => @author, :title => 'test comment', :body => 'you suck!', :source => @article)
    sent = ActionMailer::Base.deliveries.first
    assert_match /#{@author.name}/, sent.body.to_s
  end

  should 'display unauthenticated author name and email in delivered mail' do
    create_comment_and_notify(:name => 'flatline', :email => 'flatline@invalid.com', :title => 'test comment', :body => 'you suck!', :source => @article )
    sent = ActionMailer::Base.deliveries.first
    assert_match /flatline/, sent.body.to_s
    assert_match /flatline@invalid.com/, sent.body.to_s
  end

  should 'not deliver mail if notify comments is false' do
    @article.update_attribute(:notify_comments, false)
    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      create_comment_and_notify(:author => @author, :title => 'test comment', :body => 'you suck!', :source => @article)
    end
  end

  should 'include comment title in the e-mail' do
    create_comment_and_notify(:author => @author, :title => 'comment title', :body => 'comment body', :source => @article)
    sent = ActionMailer::Base.deliveries.first
    assert_match /comment title/, sent.body.to_s
  end

  should 'include comment text in the e-mail' do
    create_comment_and_notify(:author => @author, :title => 'comment title', :body => 'comment body', :source => @article)
    sent = ActionMailer::Base.deliveries.first
    assert_match /comment body/, sent.body.to_s
  end

  should "deliver mail to followers" do
    author = create_user('follower_author').person
    follower = create_user('follower').person
    @article.followers += [follower.email]
    @article.save!
    create_comment_and_notify(:source => @article, :author => author, :title => 'comment title', :body => 'comment body')
    assert_includes ActionMailer::Base.deliveries.map(&:bcc).flatten, follower.email
  end

  should "not deliver follower's mail about new comment to comment's author" do
    follower = create_user('follower').person
    create_comment_and_notify(:source => @article, :author => follower, :title => 'comment title', :body => 'comment body')
    assert_not_includes ActionMailer::Base.deliveries.map(&:bcc).flatten, follower.email
  end

  should 'not deliver mail to comments author' do
    community = fast_create(Community)
    community.add_admin @profile
    community.add_admin @author

    article = fast_create(Article, :name => 'Article test', :profile_id => community.id, :notify_comments => true)
    create_comment_and_notify(:source => @article, :author => @author, :title => 'comment title', :body => 'comment body')
    sent = ActionMailer::Base.deliveries.first
    assert_not_includes sent.to, @author.email
  end

  private

  def create_comment_and_notify(args)
    create(Comment, args)
    process_delayed_job_queue
  end

  def read_fixture(action)
    IO.readlines("#{FIXTURES_PATH}/mail_sender/#{action}")
  end

  def encode(subject)
    quoted_printable(subject, CHARSET)
  end

end
