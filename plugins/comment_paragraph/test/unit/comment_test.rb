require_relative '../test_helper'

class CommentTest < ActiveSupport::TestCase

  def setup
    profile = fast_create(Community)
    @article = fast_create(Article, :profile_id => profile.id)
  end

  attr_reader :article

  should 'return comments that belongs to a specified paragraph' do
    comment1 = fast_create(Comment, :paragraph_uuid => '1', :source_id => article.id)
    comment2 = fast_create(Comment, :paragraph_uuid => nil, :source_id => article.id)
    comment3 = fast_create(Comment, :paragraph_uuid => '2', :source_id => article.id)
    assert_equal [comment1], article.comments.in_paragraph('1')
  end

  should 'return comments that do not belongs to any paragraph' do
    comment1 = fast_create(Comment, :paragraph_uuid => '1', :source_id => article.id)
    comment2 = fast_create(Comment, :paragraph_uuid => nil, :source_id => article.id)
    comment3 = fast_create(Comment, :paragraph_uuid => '2', :source_id => article.id)
    assert_equal [comment2], article.comments.without_paragraph
  end

end
