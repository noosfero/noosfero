require 'test_helper'

class MarkCommentAsReadPlugin::CommentTest < ActiveSupport::TestCase

  def setup
    @person = create_user('user').person
    @article = TinyMceArticle.create!(:profile => @person, :name => 'An article')
    @comment = Comment.create!(:title => 'title', :body => 'body', :author => @person, :source => @article)
  end

  should 'mark comment as read' do
    refute @comment.marked_as_read?(@person)
    @comment.mark_as_read(@person)
    assert @comment.marked_as_read?(@person)
  end

  should 'do not mark a comment as read again' do
    @comment.mark_as_read(@person)
    assert_raise ActiveRecord::RecordNotUnique do
      @comment.mark_as_read(@person)
    end
  end

  should 'mark comment as not read' do
    @comment.mark_as_read(@person)
    assert @comment.marked_as_read?(@person)
    @comment.mark_as_not_read(@person)
    refute @comment.marked_as_read?(@person)
  end

  should 'return comments marked as read for a user' do
    person2 = create_user('user2').person
    @comment.mark_as_read(@person)
    assert_equal [], @article.comments.marked_as_read(@person) - [@comment]
    assert_equal [], @article.comments.marked_as_read(person2)
  end

end
