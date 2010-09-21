require File.dirname(__FILE__) + '/../test_helper'

class PublishedArticleTest < ActiveSupport::TestCase

  def setup
    @profile = create_user('test_user').person
    @article = fast_create(Article, :profile_id => @profile.id, :name => 'test_article', :body => 'some trivial body')
  end
  
  should 'have a reference article and profile' do
    prof = fast_create(Community)
    p = PublishedArticle.create(:reference_article => @article, :profile => prof)

    assert p
    assert_equal prof, p.profile
    assert_equal @article, p.reference_article
  end

  should 'have a different name than reference article' do
    prof = fast_create(Community)
    p = PublishedArticle.create(:reference_article => @article, :profile => prof, :name => 'other title')

    assert_equal 'other title', p.name
    assert_not_equal @article.name, p.name
    
  end

  should 'use name of reference article a default name' do
    prof = fast_create(Community)
    p = PublishedArticle.create!(:reference_article => @article, :profile => prof)

    assert_equal @article.name, p.name
  end

  should 'not be created in blog if community does not have a blog' do
    parent = mock
    @article.expects(:parent).returns(parent)
    parent.expects(:blog?).returns(true)
    prof = fast_create(Community)
    p = PublishedArticle.create!(:reference_article => @article, :profile => prof)

    assert !prof.has_blog?
    assert_nil p.parent
  end

  should 'be created in community blog if came from a blog' do
    parent = mock
    @article.expects(:parent).returns(parent)
    parent.expects(:blog?).returns(true)
    prof = fast_create(Community)
    prof.articles << Blog.new(:profile => prof, :name => 'Blog test')
    p = PublishedArticle.create!(:reference_article => @article, :profile => prof)

    assert_equal p.parent, prof.blog
  end

  should 'not be created in community blog if did not come from a blog' do
    parent = mock
    @article.expects(:parent).returns(parent)
    parent.expects(:blog?).returns(false)
    prof = fast_create(Community)
    blog = fast_create(Blog, :profile_id => prof.id, :name => 'Blog test')
    p = PublishedArticle.create!(:reference_article => @article, :profile => prof)

    assert_nil p.parent
  end

  should "use author of original article as its author" do
    original = Article.new(:last_changed_by => @profile)
    community = Community.new
    published = PublishedArticle.new(:reference_article => original, :profile => community)
    assert_equal @profile, published.author
  end

  should 'use owning profile as author when there is no referenced article yet' do
    assert_equal @profile, PublishedArticle.new(:profile => @profile).author
  end

  should 'have parent if defined' do
    prof = fast_create(Community)
    folder = fast_create(Folder, :name => 'folder test', :profile_id => prof.id)
    p = PublishedArticle.create(:reference_article => @article, :profile => prof, :parent => folder)

    assert p
    assert_equal folder, p.parent
  end

  should 'use to_html from reference_article' do
    prof = fast_create(Community)
    p = PublishedArticle.create!(:reference_article => @article, :profile => prof)

    assert_equal @article.to_html, p.to_html
  end

  should 'use to_html from reference_article when is Textile' do
    prof = fast_create(Community)
    textile_article = fast_create(TextileArticle, :name => 'textile_article', :body => '*my text*', :profile_id => prof.id)
    p = PublishedArticle.create!(:reference_article => textile_article, :profile => prof)

    assert_equal textile_article.to_html, p.to_html
  end

  should 'display message when reference_article does not exist' do
    prof = fast_create(Community)
    textile_article = fast_create(TextileArticle, :name => 'textile_article', :body => '*my text*', :profile_id => prof.id)
    p = PublishedArticle.create!(:reference_article => textile_article, :profile => prof)
    textile_article.destroy
    p.reload

    assert_match /removed/, p.to_html
  end

  should 'use abstract from referenced article' do
    original = Article.new(:abstract => 'this is the abstract')
    published = PublishedArticle.new
    published.stubs(:reference_article).returns(original)

    assert_equal 'this is the abstract', published.abstract
  end

  should 'return no abstract when reference_article does not exist' do
    published = PublishedArticle.new
    published.stubs(:reference_article).returns(nil)

    assert_nil published.abstract
  end

  should 'specified parent overwrite blog' do
    parent = mock
    @article.stubs(:parent).returns(parent)
    parent.stubs(:blog?).returns(true)
    prof = fast_create(Community)
    prof.articles << Blog.new(:profile => prof, :name => 'Blog test')
    new_parent = fast_create(Folder, :profile_id => prof.id, :name => 'Folder test')
    p = PublishedArticle.create!(:reference_article => @article, :profile => prof, :parent => new_parent)

    assert_equal p.parent, new_parent
  end

  should 'notifiable be true' do
    a = fast_create(PublishedArticle)
    assert a.notifiable?
  end

  should 'notify activity on create' do
    ActionTracker::Record.delete_all
    a = fast_create(Article)
    PublishedArticle.create! :reference_article => a, :name => 'test', :profile_id => fast_create(Profile).id, :published => true
    assert_equal 1, ActionTracker::Record.count
  end

  should 'notify with different trackers activity create with different targets' do
    ActionTracker::Record.delete_all
    profile = fast_create(Profile)
    a = fast_create(Article)
    PublishedArticle.create! :reference_article => a, :name => 'bar', :profile_id => profile.id, :published => true
    a = fast_create(Article)
    PublishedArticle.create! :reference_article => a, :name => 'another bar', :profile_id => profile.id, :published => true
    assert_equal 1, ActionTracker::Record.count
    a = fast_create(Article)
    PublishedArticle.create! :reference_article => a, :name => 'another bar', :profile_id => fast_create(Profile).id, :published => true
    assert_equal 2, ActionTracker::Record.count
  end

  should 'notify activity on update' do
    ActionTracker::Record.delete_all
    a = fast_create(Article)
    a = PublishedArticle.create! :reference_article => a, :name => 'bar', :profile_id => fast_create(Profile).id, :published => true
    assert_equal 1, ActionTracker::Record.count
    a.name = 'foo'
    a.save!
    assert_equal 2, ActionTracker::Record.count
  end

  should 'notify with different trackers activity update with different targets' do
    ActionTracker::Record.delete_all
    a = fast_create(Article)
    a1 = PublishedArticle.create! :reference_article => a, :name => 'bar', :profile_id => fast_create(Profile).id, :published => true
    a = fast_create(Article)
    a2 = PublishedArticle.create! :reference_article => a, :name => 'another bar', :profile_id => fast_create(Profile).id, :published => true
    assert_equal 2, ActionTracker::Record.count
    a1.name = 'foo'
    a1.save!
    assert_equal 3, ActionTracker::Record.count
    a2.name = 'another foo'
    a2.save!
    assert_equal 4, ActionTracker::Record.count
  end

  should 'notify activity on destroy' do
    ActionTracker::Record.delete_all
    a = fast_create(Article)
    a = PublishedArticle.create! :reference_article => a, :name => 'bar', :profile_id => fast_create(Profile).id, :published => true
    assert_equal 1, ActionTracker::Record.count
    a.destroy
    assert_equal 2, ActionTracker::Record.count
  end

  should 'notify different activities when destroy articles with diferrents targets' do
    ActionTracker::Record.delete_all
    a = fast_create(Article)
    a1 = PublishedArticle.create! :reference_article => a, :name => 'bar', :profile_id => fast_create(Profile).id, :published => true
    a = fast_create(Article)
    a2 = PublishedArticle.create! :reference_article => a, :name => 'another bar', :profile_id => fast_create(Profile).id, :published => true
    assert_equal 2, ActionTracker::Record.count
    a1.destroy
    assert_equal 3, ActionTracker::Record.count
    a2.destroy
    assert_equal 4, ActionTracker::Record.count
  end

  should "the tracker action target be defined as Community by custom_target method on articles'creation in communities" do
    ActionTracker::Record.delete_all
    community = fast_create(Community)
    p1 = Person.first
    community.add_member(p1)
    assert p1.is_member_of?(community)
    a = fast_create(Article)
    article = PublishedArticle.create! :reference_article => a, :name => 'test', :profile_id => community.id
    assert_equal true, article.published?
    assert_equal true, article.notifiable?
    assert_equal false, article.image?
    assert_equal Community, article.profile.class
    assert_equal Community, ActionTracker::Record.last.target.class
  end

  should "the tracker action target be defined as person by custom_target method on articles'creation in profile" do
    ActionTracker::Record.delete_all
    person = Person.first
    a = fast_create(Article)
    article = PublishedArticle.create! :reference_article => a, :name => 'test', :profile_id => person.id
    assert_equal true, article.published?
    assert_equal true, article.notifiable?
    assert_equal false, article.image?
    assert_equal Person, article.profile.class
    assert_equal person, ActionTracker::Record.last.target
  end

  should 'not notify activity if the article is not advertise' do
    ActionTracker::Record.delete_all
    article = fast_create(Article)
    a = PublishedArticle.create! :reference_article => article, :name => 'bar', :profile_id => fast_create(Profile).id, :published => true, :advertise => false
    assert_equal true, a.published?
    assert_equal true, a.notifiable?
    assert_equal false, a.image?
    assert_equal false, a.profile.is_a?(Community)
    assert_equal 0, ActionTracker::Record.count
  end

  should "have defined the is_trackable method defined" do
    assert PublishedArticle.method_defined?(:is_trackable?)
  end

  should "the common trackable conditions return the correct value" do
    a =  PublishedArticle.new
    a.published = a.advertise = true
    assert_equal true, a.published?
    assert_equal true, a.notifiable?
    assert_equal true, a.advertise?
    assert_equal true, a.is_trackable?
   
    a.published=false
    assert_equal false, a.published?
    assert_equal false, a.is_trackable?

    a.published=true
    a.advertise=false
    assert_equal false, a.advertise?
    assert_equal false, a.is_trackable?
  end

end
