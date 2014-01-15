require File.dirname(__FILE__) + '/../test_helper'

class ArticleTest < ActiveSupport::TestCase

  def setup
    profile = fast_create(Community)
    @article = fast_create(Article, :profile_id => profile.id)
  end

  attr_reader :article

  should 'return group comments from article' do
    comment1 = fast_create(Comment, :group_id => 1, :source_id => article.id)
    comment2 = fast_create(Comment, :group_id => nil, :source_id => article.id)
    assert_equal [comment1], article.group_comments
  end

  should 'do not allow a exclusion of a group comment macro if this group has comments' do
    article.body = "<div class=\"macro\" data-macro-group_id=2></div>"
    comment1 = fast_create(Comment, :group_id => 1, :source_id => article.id)
    assert !article.save
    assert_equal 'Not empty group comment cannot be removed', article.errors[:base]
  end

  should 'allow save if comment group macro is not removed for group with comments' do
    article.body = "<div class=\"macro\" data-macro-group_id=1></div>"
    comment1 = fast_create(Comment, :group_id => 1, :source_id => article.id)
    assert article.save
  end

  should 'do not validate empty group if article body is not changed' do
    article.body = "<div class=\"macro\" data-macro-group_id=2></div>"
    assert article.save
    comment1 = fast_create(Comment, :group_id => 1, :source_id => article.id)
    article.name = article.name + 'changed'
    assert article.save
  end

end
