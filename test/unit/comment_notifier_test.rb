require File.dirname(__FILE__) + '/../test_helper'

class CommentNotifierTest < Test::Unit::TestCase
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  CHARSET = "utf-8"

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    @profile = create_user('user_comment_test').person
    @article = fast_create(Article, :name => 'Article test', :profile_id => @profile.id, :notify_comments => true)
    Comment.skip_captcha!
  end

  should 'deliver mail after make aarticle commment' do
    assert_difference ActionMailer::Base.deliveries, :size do
      @article.comments << Comment.new(:author => @profile, :title => 'test comment', :body => 'you suck!')
    end
  end

  should 'deliver mail to owner of article' do
    @article.comments << Comment.new(:author => @profile, :title => 'test comment', :body => 'you suck!')
    sent = ActionMailer::Base.deliveries.first
    assert_equal [@profile.email], sent.to
  end

  should 'display author name in delivered mail' do
    @article.comments << Comment.new(:author => @profile, :title => 'test comment', :body => 'you suck!')
    sent = ActionMailer::Base.deliveries.first
    assert_match /user_comment_test/, sent.body
  end

  should 'display unauthenticated author name and email in delivered mail' do
    @article.comments << Comment.new(:name => 'flatline', :email => 'flatline@invalid.com', :title => 'test comment', :body => 'you suck!')
    sent = ActionMailer::Base.deliveries.first
    assert_match /flatline/, sent.body
    assert_match /flatline@invalid.com/, sent.body
  end

  should 'not deliver mail if notify comments is false' do
    @article.update_attribute(:notify_comments, false)
    assert_no_difference ActionMailer::Base.deliveries, :size do
      @article.comments << Comment.new(:author => @profile, :title => 'test comment', :body => 'you suck!')
    end
  end

  should 'include comment title in the e-mail' do
    @article.comments << Comment.new(:author => @profile, :title => 'comment title', :body => 'comment title')
    sent = ActionMailer::Base.deliveries.first
    assert_match /comment title/, sent.body
  end

  should 'include comment text in the e-mail' do
    @article.comments << Comment.new(:author => @profile, :title => 'comment title', :body => 'comment body')
    sent = ActionMailer::Base.deliveries.first
    assert_match /comment body/, sent.body
  end

  should 'not deliver mail if has no notification emails' do
    community = fast_create(Community)
    assert_equal [], community.notification_emails
    article = fast_create(Article, :name => 'Article test', :profile_id => community.id, :notify_comments => true)
    assert_no_difference ActionMailer::Base.deliveries, :size do
      article.comments << Comment.new(:author => @profile, :title => 'test comment', :body => 'there is no addresses to send notification')
    end
  end

  private

    def read_fixture(action)
      IO.readlines("#{FIXTURES_PATH}/mail_sender/#{action}")
    end

    def encode(subject)
      quoted_printable(subject, CHARSET)
    end

end
