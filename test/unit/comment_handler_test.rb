require_relative "../test_helper"

class CommentHandlerTest < ActiveSupport::TestCase

  should 'receive comment id' do
    handler = CommentHandler.new(99)
    assert_equal 99, handler.comment_id
  end

  should 'not crash with unexisting comment' do
    handler = CommentHandler.new(-1)
    handler.perform
  end

  should 'call Comment#whatever_method' do
    handler = CommentHandler.new(-1, :whatever_method)
    comment = Comment.new
    Comment.stubs(:find).with(-1).returns(comment)
    comment.expects(:whatever_method)

    handler.perform
  end

  should 'save locale from creation context and not change current locale' do
    FastGettext.stubs(:locale).returns("pt")
    handler = CommentHandler.new(5, :whatever_method)

    FastGettext.stubs(:locale).returns("en")
    assert_equal "pt", handler.locale

    handler.perform
    assert_equal "en", FastGettext.locale
  end
end
