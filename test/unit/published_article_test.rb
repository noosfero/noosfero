require File.dirname(__FILE__) + '/../test_helper'

class PublishedArticleTest < ActiveSupport::TestCase

  def setup
    @profile = create_user('test_user').person
    @article = @profile.articles.create!(:name => 'test_article', :body => 'some trivial body')
  end
  
  
  should 'have a reference article and profile' do
    prof = Community.create!(:name => 'test_comm', :identifier => 'test_comm')
    p = PublishedArticle.create(:reference_article => @article, :profile => prof)

    assert p
    assert_equal prof, p.profile
    assert_equal @article, p.reference_article
  end

  should 'have a different name than reference article' do
    prof = Community.create!(:name => 'test_comm', :identifier => 'test_comm')
    p = PublishedArticle.create(:reference_article => @article, :profile => prof, :name => 'other title')

    assert_equal 'other title', p.name
    assert_not_equal @article.name, p.name
    
  end

  should 'use name of reference article a default name' do
    prof = Community.create!(:name => 'test_comm', :identifier => 'test_comm')
    p = PublishedArticle.create!(:reference_article => @article, :profile => prof)

    assert_equal @article.name, p.name
  end

  should 'not be created in blog if community does not have a blog' do
    parent = mock
    @article.expects(:parent).returns(parent)
    parent.expects(:blog?).returns(true)
    prof = Community.create!(:name => 'test_comm', :identifier => 'test_comm')
    p = PublishedArticle.create!(:reference_article => @article, :profile => prof)

    assert !prof.has_blog?
    assert_nil p.parent
  end

  should 'be created in community blog if came from a blog' do
    parent = mock
    @article.expects(:parent).returns(parent)
    parent.expects(:blog?).returns(true)
    prof = Community.create!(:name => 'test_comm', :identifier => 'test_comm')
    prof.articles << Blog.new(:profile => prof, :name => 'Blog test')
    p = PublishedArticle.create!(:reference_article => @article, :profile => prof)

    assert_equal p.parent, prof.blog
  end

  should 'not be created in community blog if did not come from a blog' do
    parent = mock
    @article.expects(:parent).returns(parent)
    parent.expects(:blog?).returns(false)
    prof = Community.create!(:name => 'test_comm', :identifier => 'test_comm')
    blog = Blog.create!(:profile => prof, :name => 'Blog test')
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
    prof = Community.create!(:name => 'test_comm', :identifier => 'test_comm')
    folder = Folder.create(:name => 'folder test', :profile => prof)
    p = PublishedArticle.create(:reference_article => @article, :profile => prof, :parent => folder)

    assert p
    assert_equal folder, p.parent
  end

  should 'use to_html from reference_article' do
    prof = Community.create!(:name => 'test_comm', :identifier => 'test_comm')
    p = PublishedArticle.create!(:reference_article => @article, :profile => prof)

    assert_equal @article.to_html, p.to_html
  end

  should 'use to_html from reference_article when is Textile' do
    prof = Community.create!(:name => 'test_comm', :identifier => 'test_comm')
    textile_article = TextileArticle.new(:name => 'textile_article', :body => '*my text*', :profile => prof)
    p = PublishedArticle.create!(:reference_article => textile_article, :profile => prof)

    assert_equal textile_article.to_html, p.to_html
  end

  should 'display message when reference_article does not exist' do
    prof = Community.create!(:name => 'test_comm', :identifier => 'test_comm')
    textile_article = TextileArticle.new(:name => 'textile_article', :body => '*my text*', :profile => prof)
    p = PublishedArticle.create!(:reference_article => textile_article, :profile => prof)
    textile_article.destroy
    p.reload

    assert_match /removed/, p.to_html
  end

  should 'specified parent overwrite blog' do
    parent = mock
    @article.stubs(:parent).returns(parent)
    parent.stubs(:blog?).returns(true)
    prof = Community.create!(:name => 'test_comm', :identifier => 'test_comm')
    prof.articles << Blog.new(:profile => prof, :name => 'Blog test')
    new_parent = Folder.create!(:profile => prof, :name => 'Folder test')
    p = PublishedArticle.create!(:reference_article => @article, :profile => prof, :parent => new_parent)

    assert_equal p.parent, new_parent
  end

 should 'provide first paragraph of HTML version' do
    prof = Community.create!(:name => 'test_comm', :identifier => 'test_comm')
    a = Article.create!(:name => 'my article', :profile_id => prof.id)
    a.expects(:body).returns('<p>the first paragraph of the article</p> The second paragraph')
    p = PublishedArticle.create(:reference_article => a, :profile => prof)
    assert_equal '<p>the first paragraph of the article</p>', p.first_paragraph
  end

end
