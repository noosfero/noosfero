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

    assert_optional Comment.new, :name
    assert_optional Comment.new, :email

    # if given name, require email
    c1 = Comment.new
    c1.name = 'My Name'
    assert_mandatory c1, :email

    # if given email, require name
    c2 = Comment.new
    c2.email = 'my@email.com'
    assert_mandatory c2, :name
  end

  should 'accept either an authenticated or unauthenticated author' do
    assert_mandatory Comment.new, :author_id

    c1 = Comment.new
    c1.author = create_user('someperson').person
    c1.name = 'my name'
    c1.valid?
    assert c1.errors.invalid?(:name)
  end

end
