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

  should 'update counter cache in article' do
    owner = create_user('testuser').person
    art = owner.articles.build(:name => 'ytest'); art.save!

    cc = art.comments_count
    art.comments.build(:title => 'test comment', :body => 'anything', :author => owner).save!
    art.reload
    assert_equal cc + 1, art.comments_count
  end

  should 'provide author name for authenticated authors' do
    owner = create_user('testuser').person
    assert_equal 'testuser', Comment.new(:author => owner).author_name
  end

  should 'provide author name for unauthenticated author' do
    assert_equal 'anonymous coward', Comment.new(:name => 'anonymous coward').author_name
  end

  should 'provide url to comment' do
    art = Article.new
    art.expects(:url).returns({ :controller => 'lala', :action => 'something' })
    comment = Comment.new(:article => art)
    comment.expects(:id).returns(9876)

    assert_equal({ :controller => 'lala', :action => 'something', :anchor => 'comment-9876'}, comment.url)
  end

  should 'provide anchor' do
    comment = Comment.new
    comment.expects(:id).returns(4321)
    assert_equal 'comment-4321', comment.anchor
  end

  should 'be searched by contents of title' do 
    owner = create_user('testuser').person
    art = owner.articles.build(:name => 'ytest'); art.save!
    c1 = art.comments.build(:title => 'a nice comment', :body => 'anything', :author => owner); c1.save!

    assert_includes Comment.find_by_contents('nice'), c1
  end

  should 'be searched by contents of body' do 
    owner = create_user('testuser').person
    art = owner.articles.build(:name => 'ytest'); art.save!
    c1 = art.comments.build(:title => 'test comment', :body => 'anything', :author => owner); c1.save!

    assert_includes Comment.find_by_contents('anything'), c1
  end

end
