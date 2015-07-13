require_relative '../test_helper'

class CommentTest < ActiveSupport::TestCase

  def setup
    profile = fast_create(Community)
    @article = fast_create(Article, :profile_id => profile.id)
  end

  attr_reader :article

  should 'return comments that belongs to a specified group' do
    comment1 = fast_create(Comment, :group_id => 1, :source_id => article.id)
    comment2 = fast_create(Comment, :group_id => nil, :source_id => article.id)
    comment3 = fast_create(Comment, :group_id => 2, :source_id => article.id)
    assert_equal [comment1], article.comments.in_group(1)
  end

  should 'return comments that do not belongs to any group' do
    comment1 = fast_create(Comment, :group_id => 1, :source_id => article.id)
    comment2 = fast_create(Comment, :group_id => nil, :source_id => article.id)
    comment3 = fast_create(Comment, :group_id => 2, :source_id => article.id)
    assert_equal [comment2], article.comments.without_group
  end

end
