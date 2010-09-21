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
    assert_mandatory c1, :email, 'my@email.com'

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

  should 'provide empty text for author name if user was removed ' do
    assert_equal '', Comment.new(:author_id => 9999).author_name
  end

  should "provide author e-mail for athenticated authors" do
    owner = create_user('testuser').person
    assert_equal owner.email, Comment.new(:author => owner).author_email
  end

  should "provide author e-mail for unauthenticated author" do
    assert_equal 'my@email.com', Comment.new(:email => 'my@email.com').author_email
  end

  should 'provide author link for authenticated author' do
    author = Person.new
    author.expects(:url).returns('http://blabla.net/author')
    assert_equal  'http://blabla.net/author', Comment.new(:author => author).author_link
  end

  should 'provide author e-mail as author link for unauthenticated author' do
    assert_equal 'my@email.com', Comment.new(:email => 'my@email.com').author_link
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

  should 'be able to find recent comments' do
    Comment.delete_all

    owner = create_user('testuser').person
    art = owner.articles.build(:name => 'ytest'); art.save!
    comments = []
    3.times do
      comments.unshift art.comments.create!(:title => 'a test comment', :body => 'bla', :author => owner)
    end

    assert_equal comments, Comment.recent
  end

  should 'be able to find recent comments with limit' do
    Comment.delete_all

    owner = create_user('testuser').person
    art = owner.articles.build(:name => 'ytest'); art.save!
    comments = []
    3.times do
      comments.unshift art.comments.create!(:title => 'a test comment', :body => 'bla', :author => owner)
    end

    comments.pop

    assert_equal comments, Comment.recent(2)
  end

  should 'not accept invalid email' do
    c = Comment.new(:name => 'My Name', :email => 'my@invalid')
    c.valid?
    assert c.errors.invalid?(:email)
  end

  should 'notify article to reindex after saving' do
    owner = create_user('testuser').person
    article = owner.articles.create!(:name => 'test', :body => '...')

    article.expects(:comments_updated)

    c1 = article.comments.new(:title => "A comment", :body => '...', :author => owner)
    c1.stubs(:article).returns(article)
    c1.save!
  end

  should 'notify article to reindex after being removed' do
    owner = create_user('testuser').person
    article = owner.articles.create!(:name => 'test', :body => '...')
    c1 = article.comments.create!(:title => "A comment", :body => '...', :author => owner)

    c1.stubs(:article).returns(article)
    article.expects(:comments_updated)
    c1.destroy
  end

  should 'generate links to comments on images with view set to true' do
    owner = create_user('testuser').person
    image = UploadedFile.create!(:profile => owner, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'))
    comment = image.comments.create!(:article => image, :author => owner, :title => 'a random comment', :body => 'just another comment')

    assert comment.url[:view]
  end

  should 'not fill fields with javascript' do
    owner = create_user('testuser').person
    article = owner.articles.create!(:name => 'test', :body => '...')
    javascript = "<script>alert('XSS')</script>"
    comment = article.comments.create!(:article => article, :name => javascript, :title => javascript, :body => javascript, :email => 'cracker@test.org')
    assert_no_match(/<script>/, comment.name)
  end

  should 'sanitize required fields before validation' do
    owner = create_user('testuser').person
    article = owner.articles.create(:name => 'test', :body => '...')
    comment = article.comments.new(:title => '<h1 title </h1>', :body => '<h1 body </h1>', :name => '<h1 name </h1>', :email => 'cracker@test.org')
    comment.valid?

    assert comment.errors.invalid?(:name)
    assert comment.errors.invalid?(:title)
    assert comment.errors.invalid?(:body)
  end

  should 'escape malformed html tags' do
    owner = create_user('testuser').person
    article = owner.articles.create(:name => 'test', :body => '...')
    comment = article.comments.new(:title => '<h1 title </h1>>> sd f <<', :body => '<h1>> sdf><asd>< body </h1>', :name => '<h1 name </h1>>><<dfsf<sd', :email => 'cracker@test.org')
    comment.valid?

    assert_no_match /[<>]/, comment.title
    assert_no_match /[<>]/, comment.body
    assert_no_match /[<>]/, comment.name
  end

  should 'use an existing image for deleted comments' do
    image = Comment.new.removed_user_image
    assert File.exists?(File.join(Rails.root, 'public', image)), "#{image} does not exist."
  end

  should 'track action when comment is created' do
    owner = create_user('testuser').person
    article = owner.articles.create!(:name => 'test', :body => '...')
    comment = article.comments.create!(:article => article, :name => 'foo', :title => 'bar', :body => 'my comment', :email => 'cracker@test.org')
    ta = ActionTracker::Record.last
    assert_equal 'bar', ta.get_title
    assert_equal 'my comment', ta.get_body
    assert_equal 'test', ta.get_article_title
    assert_equal article.url, ta.get_article_url
    assert_equal comment.url, ta.get_url
  end

  should 'have the action_tracker_target defined' do
    assert Comment.method_defined?(:action_tracker_target)
  end

  should "have the action_tracker_target be the articles's profile" do
    owner = create_user('testuser').person
    article = owner.articles.create!(:name => 'test', :body => '...')
    comment = article.comments.create!(:article => article, :name => 'foo', :title => 'bar', :body => 'my comment', :email => 'cracker@test.org')
    ta = ActionTracker::Record.last
    assert_equal owner, ta.target
  end

end
