require 'test_helper'

class AntiSpamPlugin::CommentWrapperTest < ActiveSupport::TestCase

  def setup
    @comment = build(Comment,
      :title => 'comment title',
      :body => 'comment body',
      :name => 'foo',
      :email => 'foo@example.com',
      :ip_address => '1.2.3.4',
      :user_agent => 'Some Good Browser (I hope)',
      :referrer => 'http://noosfero.org/'
    )
    @wrapper = AntiSpamPlugin::CommentWrapper.new(@comment)
  end

  should 'get contents' do
    assert_equal @comment.body, @wrapper.content
  end

  should 'get author name' do
    assert_equal @comment.author_name, @wrapper.author
  end

  should 'get author email' do
    assert_equal @comment.author_email, @wrapper.author_email
  end

  should 'get IP address' do
    assert_equal @comment.ip_address, @wrapper.user_ip
  end

  should 'get User-Agent' do
    assert_equal @comment.user_agent, @wrapper.user_agent
  end

  should 'get get Referrer' do
    assert_equal @comment.referrer, @wrapper.referrer
  end

end
