require File.dirname(__FILE__) + '/../test_helper'

class CommentTest < Test::Unit::TestCase

  should 'have a name and require it' do
    assert_mandatory(Comment.new, :title)
  end

  should 'have a body and require it' do
    assert_mandatory(Comment.new, :body)
  end

  should 'belong to an article' do
    c = Comment.new
    assert_raise ActiveRecord::AssociationTypeMismatch do
      c.article = 1
    end
    assert_nothing_raised do
      c.article = Article.new
    end
  end

  should 'record authenticated author' do
    c = Comment.new
    assert_raise ActiveRecord::AssociationTypeMismatch do
      c.author = 1
    end
    assert_raise ActiveRecord::AssociationTypeMismatch do
      c.author = Profile
    end
    assert_nothing_raised do
      c.author = Person.new
    end
  end

  should 'record unauthenticated author' do
    flunk 'not yet'
  end

end
