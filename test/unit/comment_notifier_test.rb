require File.dirname(__FILE__) + '/../test_helper'

class CommentNotifierTest < Test::Unit::TestCase
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  CHARSET = "utf-8"

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    @expected = TMail::Mail.new
    @expected.set_content_type "text", "plain", { "charset" => CHARSET }
  end

  should 'deliver mail after make aarticle commment' do
    p = create_user('user_comment_test').person
    a = Article.create!(:name => 'Article test', :profile => p, :notify_comments => true)
    assert_difference ActionMailer::Base.deliveries, :size do
      a.comments << Comment.new(:author => p, :title => 'test comment', :body => 'you suck!')
    end
  end

  should 'deliver mail to owner of article' do
    p = create_user('user_comment_test').person
    a = Article.create!(:name => 'Article test', :profile => p, :notify_comments => true)
    a.comments << Comment.new(:author => p, :title => 'test comment', :body => 'you suck!')
    sent = ActionMailer::Base.deliveries.first
    assert_equal [p.email], sent.to
  end

  should 'display author name in delivered mail' do
    p = create_user('user_comment_test').person
    a = Article.create!(:name => 'Article test', :profile => p, :notify_comments => true)
    a.comments << Comment.new(:author => p, :title => 'test comment', :body => 'you suck!')
    sent = ActionMailer::Base.deliveries.first
    assert_match /user_comment_test/, sent.body
  end

  should 'display unauthenticated author name and email in delivered mail' do
    p = create_user('user_comment_test').person
    a = Article.create!(:name => 'Article test', :profile => p, :notify_comments => true)
    a.comments << Comment.new(:name => 'flatline', :email => 'flatline@invalid.com', :title => 'test comment', :body => 'you suck!')
    sent = ActionMailer::Base.deliveries.first
    assert_match /flatline/, sent.body
    assert_match /flatline@invalid.com/, sent.body
  end

  should 'not deliver mail if notify comments is false' do
    p = create_user('user_comment_test').person
    a = Article.create!(:name => 'Article test', :profile => p, :notify_comments => false)
    assert_no_difference ActionMailer::Base.deliveries, :size do
      a.comments << Comment.new(:author => p, :title => 'test comment', :body => 'you suck!')
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
