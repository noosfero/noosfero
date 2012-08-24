require File.dirname(__FILE__) + '/../test_helper'

class CommentHandlerTest < ActiveSupport::TestCase

  should 'receive comment id' do
    handler = CommentHandler.new(99)
    assert_equal 99, handler.comment_id
  end

  should 'not crash with unexisting comment' do
    handler = CommentHandler.new(-1)
    handler.perform
  end

  should 'call Comment#notify_by_mail' do
    handler = CommentHandler.new(-1)
    comment = Comment.new
    Comment.stubs(:find).with(-1).returns(comment)
    comment.expects(:verify_and_notify)

    handler.perform
  end

end
