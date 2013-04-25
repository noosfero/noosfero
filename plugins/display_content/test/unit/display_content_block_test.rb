require File.dirname(__FILE__) + '/../test_helper'
class DisplayContentBlockTest < ActiveSupport::TestCase

  INVALID_KIND_OF_ARTICLE = [EnterpriseHomepage, Event, RssFeed, UploadedFile, Gallery]
  VALID_KIND_OF_ARTICLE = [RawHTMLArticle, TextArticle, TextileArticle, TinyMceArticle, Folder, Blog, Forum]

  should 'describe itself' do
    assert_not_equal Block.description, DisplayContentBlock.description
  end

  should 'is editable' do
    block = DisplayContentBlock.new
    assert block.editable?
  end

  should 'have field nodes' do
    block = DisplayContentBlock.new
    assert_respond_to block, :nodes
  end

  should 'default value of nodes be an empty array' do
    block = DisplayContentBlock.new
    assert_equal [], block.nodes
  end

  should 'not set nodes if there is no holder' do
    Article.delete_all
    a1 = fast_create(TextArticle, :name => 'test article 1', :profile_id => 1)

    checked_articles= {a1.id => true}
    block = DisplayContentBlock.new
    block.stubs(:holder).returns(nil)
    block.checked_nodes= checked_articles
    assert_equal [], block.nodes
  end

  should 'nodes be the article ids in hash of checked nodes' do
    profile = create_user('testuser').person
    Article.delete_all
    a1 = fast_create(TextileArticle, :name => 'test article 1', :profile_id => profile.id)
    a2 = fast_create(TextileArticle, :name => 'test article 2', :profile_id => profile.id)
    a3 = fast_create(TextileArticle, :name => 'test article 3', :profile_id => profile.id)

    checked_articles= {a1.id => true, a2.id => true, a3.id => false}
    block = DisplayContentBlock.new
    block.stubs(:holder).returns(profile)
    block.checked_nodes= checked_articles
    assert_equal [], [a1.id, a2.id, a3.id] - block.nodes
    assert_equal [], block.nodes - [a1.id, a2.id, a3.id]
  end

  should 'nodes be save in database' do
    profile = create_user('testuser').person
    Article.delete_all
    a1 = fast_create(TextileArticle, :name => 'test article 1', :profile_id => profile.id)
    a2 = fast_create(TextileArticle, :name => 'test article 2', :profile_id => profile.id)
    a3 = fast_create(TextileArticle, :name => 'test article 3', :profile_id => profile.id)

    checked_articles= {a1.id => true, a2.id => true, a3.id => false}
    block = DisplayContentBlock.new
    block.stubs(:holder).returns(profile)
    block.checked_nodes= checked_articles
    block.save
    block.reload
    assert_equal [], [a1.id, a2.id, a3.id] - block.nodes
    assert_equal [], block.nodes - [a1.id, a2.id, a3.id]
  end

  should 'be able to update nodes' do
    profile = create_user('testuser').person
    Article.delete_all
    a1 = fast_create(TextileArticle, :name => 'test article 1', :profile_id => profile.id)
    a2 = fast_create(TextileArticle, :name => 'test article 2', :profile_id => profile.id)
    a3 = fast_create(TextileArticle, :name => 'test article 3', :profile_id => profile.id)
    a4 = fast_create(TextileArticle, :name => 'test article 4', :profile_id => profile.id)

    checked_articles= {a1.id => true, a2.id => true, a3.id => false}
    block = DisplayContentBlock.new
    block.stubs(:holder).returns(profile)
    block.checked_nodes= checked_articles
    block.save

    block.reload
    checked_articles= {a1.id => true, a4.id => true}
    block.checked_nodes= checked_articles
    block.save
    block.reload

    assert_equal [], [a1.id, a4.id] - block.nodes
    assert_equal [], block.nodes - [a1.id, a4.id]
  end

  should "save the first children level of folders" do
    profile = create_user('testuser').person
    Article.delete_all
    a1 = fast_create(TextileArticle, :name => 'test article 1', :profile_id => profile.id)
    a2 = fast_create(TextileArticle, :name => 'test article 2', :profile_id => profile.id)
    f1 = fast_create(Folder, :name => 'test folder 1', :profile_id => profile.id)
    a3 = fast_create(TextileArticle, :name => 'test article 3', :profile_id => profile.id, :parent_id => f1.id)
    f2 = fast_create(Folder, :name => 'test folder 1', :profile_id => profile.id)
    a4 = fast_create(TextileArticle, :name => 'test article 4', :profile_id => profile.id, :parent_id => f2.id)
    a5 = fast_create(TextileArticle, :name => 'test article 5', :profile_id => profile.id, :parent_id => f2.id)

    checked_articles= {a1.id => true, a2.id => true, f1.id => false, f2.id => true}

    block = DisplayContentBlock.new
    block.stubs(:holder).returns(profile)
    block.checked_nodes= checked_articles

    assert_equal [], [a1.id, a2.id, a3.id, a4.id, a5.id] - block.nodes
    assert_equal [], block.nodes - [a1.id, a2.id, a3.id, a4.id, a5.id]
  end

  should "not save deeper level of folder's children" do
    profile = create_user('testuser').person
    Article.delete_all
    a1 = fast_create(TextileArticle, :name => 'test article 1', :profile_id => profile.id)
    a2 = fast_create(TextileArticle, :name => 'test article 2', :profile_id => profile.id)
    f1 = fast_create(Folder, :name => 'test folder 1', :profile_id => profile.id)
    a3 = fast_create(TextileArticle, :name => 'test article 3', :profile_id => profile.id, :parent_id => f1.id)
    f2 = fast_create(Folder, :name => 'test folder 1', :profile_id => profile.id, :parent_id => f1.id)
    a4 = fast_create(TextileArticle, :name => 'test article 4', :profile_id => profile.id, :parent_id => f2.id)
    a5 = fast_create(TextileArticle, :name => 'test article 5', :profile_id => profile.id, :parent_id => f2.id)

    checked_articles= {a1.id => true, a2.id => true, f1.id => false}

    block = DisplayContentBlock.new
    block.stubs(:holder).returns(profile)
    block.checked_nodes= checked_articles

    assert_equal [], [a1.id, a2.id, a3.id] - block.nodes
    assert_equal [], block.nodes - [a1.id, a2.id, a3.id]
  end

  should "save the first children level of blogs" do
    profile = create_user('testuser').person
    Article.delete_all
    a1 = fast_create(TextileArticle, :name => 'test article 1', :profile_id => profile.id)
    a2 = fast_create(TextileArticle, :name => 'test article 2', :profile_id => profile.id)
    b1 = fast_create(Blog, :name => 'test blog 1', :profile_id => profile.id)
    a3 = fast_create(TextileArticle, :name => 'test article 3', :profile_id => profile.id, :parent_id => b1.id)
    b2 = fast_create(Blog, :name => 'test blog 2', :profile_id => profile.id)
    a4 = fast_create(TextileArticle, :name => 'test article 4', :profile_id => profile.id, :parent_id => b2.id)
    a5 = fast_create(TextileArticle, :name => 'test article 5', :profile_id => profile.id, :parent_id => b2.id)

    checked_articles= {a1.id => true, a2.id => true, b1.id => false, b2.id => true}

    block = DisplayContentBlock.new
    block.stubs(:holder).returns(profile)
    block.checked_nodes= checked_articles

    assert_equal [], [a1.id, a2.id, a3.id, a4.id, a5.id] - block.nodes
    assert_equal [], block.nodes - [a1.id, a2.id, a3.id, a4.id, a5.id]
  end

  should 'TextileArticle be saved as node' do
    profile = create_user('testuser').person
    Article.delete_all
    a1 = fast_create(TextileArticle, :name => 'test article 1', :profile_id => profile.id)

    checked_articles= {a1.id => true}
    block = DisplayContentBlock.new
    block.stubs(:holder).returns(profile)
    block.checked_nodes= checked_articles
    assert_equal [], [a1.id] - block.nodes
    assert_equal [], block.nodes - [a1.id]
  end

  should 'TinyMceArticle be saved as node' do
    profile = create_user('testuser').person
    Article.delete_all
    a1 = fast_create(TinyMceArticle, :name => 'test article 1', :profile_id => profile.id)

    checked_articles= {a1.id => true}
    block = DisplayContentBlock.new
    block.stubs(:holder).returns(profile)
    block.checked_nodes= checked_articles
    assert_equal [], [a1.id] - block.nodes
    assert_equal [], block.nodes - [a1.id]
  end

  should 'RawHTMLArticle be saved as node' do
    profile = create_user('testuser').person
    Article.delete_all
    a1 = fast_create(RawHTMLArticle, :name => 'test article 1', :profile_id => profile.id)

    checked_articles= {a1.id => true}
    block = DisplayContentBlock.new
    block.stubs(:holder).returns(profile)
    block.checked_nodes= checked_articles
    assert_equal [], [a1.id] - block.nodes
    assert_equal [], block.nodes - [a1.id]
  end

  should 'Event not be saved as node' do
    profile = create_user('testuser').person
    Article.delete_all
    a1 = fast_create(TextArticle, :name => 'test article 1', :profile_id => profile.id)
    a2 = fast_create(TextArticle, :name => 'test article 2', :profile_id => profile.id)
    a3 = fast_create(Event, :name => 'test article 3', :profile_id => profile.id)

    checked_articles= {a1.id => true, a2.id => true, a3.id => false}
    block = DisplayContentBlock.new
    block.stubs(:holder).returns(profile)
    block.checked_nodes= checked_articles
    assert_equal [], [a1.id, a2.id] - block.nodes
    assert_equal [], block.nodes - [a1.id, a2.id]
  end

  should 'RSS not be saved as node' do
    profile = create_user('testuser').person
    Article.delete_all
    a1 = fast_create(TextArticle, :name => 'test article 1', :profile_id => profile.id)
    a2 = fast_create(TextArticle, :name => 'test article 2', :profile_id => profile.id)
    a3 = fast_create(RssFeed, :name => 'test article 3', :profile_id => profile.id)

    checked_articles= {a1.id => true, a2.id => true, a3.id => false}
    block = DisplayContentBlock.new
    block.stubs(:holder).returns(profile)
    block.checked_nodes= checked_articles
    assert_equal [], [a1.id, a2.id] - block.nodes
    assert_equal [], block.nodes - [a1.id, a2.id]
  end

  should 'UploadedFile not be saved as node' do
    profile = create_user('testuser').person
    Article.delete_all
    a1 = fast_create(TextArticle, :name => 'test article 1', :profile_id => profile.id)
    a2 = fast_create(TextArticle, :name => 'test article 2', :profile_id => profile.id)
    a3 = fast_create(UploadedFile, :name => 'test article 3', :profile_id => profile.id)

    checked_articles= {a1.id => true, a2.id => true, a3.id => false}
    block = DisplayContentBlock.new
    block.stubs(:holder).returns(profile)
    block.checked_nodes= checked_articles
    assert_equal [], [a1.id, a2.id] - block.nodes
    assert_equal [], block.nodes - [a1.id, a2.id]
  end

  should 'Folder not be saved as node' do
    profile = create_user('testuser').person
    Article.delete_all
    a1 = fast_create(TextArticle, :name => 'test article 1', :profile_id => profile.id)
    a2 = fast_create(TextArticle, :name => 'test article 2', :profile_id => profile.id)
    a3 = fast_create(Folder, :name => 'test article 3', :profile_id => profile.id)

    checked_articles= {a1.id => true, a2.id => true, a3.id => false}
    block = DisplayContentBlock.new
    block.stubs(:holder).returns(profile)
    block.checked_nodes= checked_articles
    assert_equal [], [a1.id, a2.id] - block.nodes
    assert_equal [], block.nodes - [a1.id, a2.id]
  end

  should 'Forum not be saved as node' do
    profile = create_user('testuser').person
    Article.delete_all
    a1 = fast_create(TextArticle, :name => 'test article 1', :profile_id => profile.id)
    a2 = fast_create(TextArticle, :name => 'test article 2', :profile_id => profile.id)
    a3 = fast_create(Forum, :name => 'test article 3', :profile_id => profile.id)

    checked_articles= {a1.id => true, a2.id => true, a3.id => false}
    block = DisplayContentBlock.new
    block.stubs(:holder).returns(profile)
    block.checked_nodes= checked_articles
    assert_equal [], [a1.id, a2.id] - block.nodes
    assert_equal [], block.nodes - [a1.id, a2.id]
  end

  should 'Gallery not be saved as node' do
    profile = create_user('testuser').person
    Article.delete_all
    a1 = fast_create(TextArticle, :name => 'test article 1', :profile_id => profile.id)
    a2 = fast_create(TextArticle, :name => 'test article 2', :profile_id => profile.id)
    a3 = fast_create(Gallery, :name => 'test article 3', :profile_id => profile.id)

    checked_articles= {a1.id => true, a2.id => true, a3.id => false}
    block = DisplayContentBlock.new
    block.stubs(:holder).returns(profile)
    block.checked_nodes= checked_articles
    assert_equal [], [a1.id, a2.id] - block.nodes
    assert_equal [], block.nodes - [a1.id, a2.id]
  end

  should 'Blog not be saved as node' do
    profile = create_user('testuser').person
    Article.delete_all
    a1 = fast_create(TextArticle, :name => 'test article 1', :profile_id => profile.id)
    a2 = fast_create(TextArticle, :name => 'test article 2', :profile_id => profile.id)
    a3 = fast_create(Blog, :name => 'test article 3', :profile_id => profile.id)

    checked_articles= {a1.id => true, a2.id => true, a3.id => false}
    block = DisplayContentBlock.new
    block.stubs(:holder).returns(profile)
    block.checked_nodes= checked_articles
    assert_equal [], [a1.id, a2.id] - block.nodes
    assert_equal [], block.nodes - [a1.id, a2.id]
  end

  should "save the article parents in parent_nodes variable" do
    profile = create_user('testuser').person
    Article.delete_all
    a1 = fast_create(TextileArticle, :name => 'test article 1', :profile_id => profile.id)
    a2 = fast_create(TextileArticle, :name => 'test article 2', :profile_id => profile.id)
    f1 = fast_create(Folder, :name => 'test folder 1', :profile_id => profile.id)
    a3 = fast_create(TextileArticle, :name => 'test article 3', :profile_id => profile.id, :parent_id => f1.id)
    f2 = fast_create(Folder, :name => 'test folder 1', :profile_id => profile.id)
    a4 = fast_create(TextileArticle, :name => 'test article 4', :profile_id => profile.id, :parent_id => f2.id)

    checked_articles= {a1.id => 1, a3.id => 1, a4.id => 1, f2.id => true}

    block = DisplayContentBlock.new
    block.stubs(:holder).returns(profile)
    block.checked_nodes= checked_articles

    assert_equal [], [f1.id, f2.id] - block.parent_nodes
    assert_equal [], block.parent_nodes - [f1.id, f2.id]
  end

  should "save deeper level of article parents in parent_nodes variable" do
    profile = create_user('testuser').person
    Article.delete_all
    a1 = fast_create(TextileArticle, :name => 'test article 1', :profile_id => profile.id)
    f1 = fast_create(Folder, :name => 'test folder 1', :profile_id => profile.id)
    f2 = fast_create(Folder, :name => 'test folder 1', :profile_id => profile.id, :parent_id => f1.id)
    f3 = fast_create(Folder, :name => 'test folder 1', :profile_id => profile.id, :parent_id => f2.id)
    a2 = fast_create(TextileArticle, :name => 'test article 4', :profile_id => profile.id, :parent_id => f3.id)

    checked_articles= {a2.id => 1}

    block = DisplayContentBlock.new
    block.stubs(:holder).returns(profile)
    block.checked_nodes= checked_articles

    assert_equal [], [f1.id, f2.id, f3.id] - block.parent_nodes
    assert_equal [], block.parent_nodes - [f1.id, f2.id, f3.id]
  end

  should "save only once time of parents if more than one children article is checked" do
    profile = create_user('testuser').person
    Article.delete_all
    a1 = fast_create(TextileArticle, :name => 'test article 1', :profile_id => profile.id)
    f1 = fast_create(Folder, :name => 'test folder 1', :profile_id => profile.id)
    a2 = fast_create(TextileArticle, :name => 'test article 3', :profile_id => profile.id, :parent_id => f1.id)
    f2 = fast_create(Folder, :name => 'test folder 1', :profile_id => profile.id)
    a3 = fast_create(TextileArticle, :name => 'test article 4', :profile_id => profile.id, :parent_id => f2.id)
    a4 = fast_create(TextileArticle, :name => 'test article 5', :profile_id => profile.id, :parent_id => f2.id)
    a5 = fast_create(TextileArticle, :name => 'test article 2', :profile_id => profile.id, :parent_id => f2.id)

    checked_articles= {a1.id => 1, a2.id => 1, a3.id => 1, a4.id => 1, a5.id => 1}

    block = DisplayContentBlock.new
    block.stubs(:holder).returns(profile)
    block.checked_nodes= checked_articles

    assert_equal [], [f1.id, f2.id] - block.parent_nodes
    assert_equal [], block.parent_nodes - [f1.id, f2.id]
  end

  should "save only once time of parents if a deeper level of children is checked" do
    profile = create_user('testuser').person
    Article.delete_all
    a1 = fast_create(TextileArticle, :name => 'test article 1', :profile_id => profile.id)
    f1 = fast_create(Folder, :name => 'test folder 1', :profile_id => profile.id)
    f2 = fast_create(Folder, :name => 'test folder 2', :profile_id => profile.id, :parent_id => f1.id)
    f3 = fast_create(Folder, :name => 'test folder 2', :profile_id => profile.id, :parent_id => f2.id)
    f4 = fast_create(Folder, :name => 'test folder 2', :profile_id => profile.id, :parent_id => f3.id)
    f5 = fast_create(Folder, :name => 'test folder 2', :profile_id => profile.id, :parent_id => f2.id)
    a2 = fast_create(TextileArticle, :name => 'test article 3', :profile_id => profile.id, :parent_id => f4.id)
    a3 = fast_create(TextileArticle, :name => 'test article 4', :profile_id => profile.id, :parent_id => f5.id)

    checked_articles= {a2.id => 1, a3.id => 1}

    block = DisplayContentBlock.new
    block.stubs(:holder).returns(profile)
    block.checked_nodes= checked_articles

    assert_equal [], [f1.id, f2.id, f3.id, f4.id, f5.id] - block.parent_nodes
    assert_equal [], block.parent_nodes - [f1.id, f2.id, f3.id, f4.id, f5.id]
  end

  should "save the folder in parent_nodes variable if it was checked" do
    profile = create_user('testuser').person
    Article.delete_all
    f1 = fast_create(Folder, :name => 'test folder 1', :profile_id => profile.id)
    a1 = fast_create(TextileArticle, :name => 'test article 1', :profile_id => profile.id, :parent_id => f1.id)
    a2 = fast_create(TextileArticle, :name => 'test article 4', :profile_id => profile.id, :parent_id => f1.id)

    checked_articles= {f1.id => 1}

    block = DisplayContentBlock.new
    block.stubs(:holder).returns(profile)
    block.checked_nodes= checked_articles

    assert_equal [], [f1.id] - block.parent_nodes
    assert_equal [], block.parent_nodes - [f1.id]
  end

  should "save the blog in parent_nodes variable if it was checked" do
    profile = create_user('testuser').person
    Article.delete_all
    b1 = fast_create(Blog, :name => 'test folder 1', :profile_id => profile.id)
    a1 = fast_create(TextileArticle, :name => 'test article 1', :profile_id => profile.id, :parent_id => b1.id)
    a2 = fast_create(TextileArticle, :name => 'test article 4', :profile_id => profile.id, :parent_id => b1.id)

    checked_articles= {b1.id => 1}

    block = DisplayContentBlock.new
    block.stubs(:holder).returns(profile)
    block.checked_nodes= checked_articles

    assert_equal [], [b1.id] - block.parent_nodes
    assert_equal [], block.parent_nodes - [b1.id]
  end

  should "save the forum in parent_nodes variable if it was checked" do
    profile = create_user('testuser').person
    Article.delete_all
    f1 = fast_create(Forum, :name => 'test folder 1', :profile_id => profile.id)
    a1 = fast_create(TextileArticle, :name => 'test article 1', :profile_id => profile.id, :parent_id => f1.id)
    a2 = fast_create(TextileArticle, :name => 'test article 4', :profile_id => profile.id, :parent_id => f1.id)

    checked_articles= {f1.id => 1}

    block = DisplayContentBlock.new
    block.stubs(:holder).returns(profile)
    block.checked_nodes= checked_articles

    assert_equal [], [f1.id] - block.parent_nodes
    assert_equal [], block.parent_nodes - [f1.id]
  end

  should "return all root articles from profile" do
    profile = create_user('testuser').person
    Article.delete_all
    a1 = fast_create(TextileArticle, :name => 'test article 1', :profile_id => profile.id)
    a2 = fast_create(TextileArticle, :name => 'test article 2', :profile_id => profile.id)
    a3 = fast_create(TextileArticle, :name => 'test article 3', :profile_id => profile.id, :parent_id => a2.id)

    block = DisplayContentBlock.new
    block.nodes= [a1.id, a2.id, a3.id]
    box = mock()
    box.stubs(:owner).returns(profile)
    block.stubs(:box).returns(box)
    assert_equal [], [a1, a2] - block.articles_of_parent
    assert_equal [], block.articles_of_parent - [a1, a2]
  end

  should "return all children of an articles's profile" do
    profile = create_user('testuser').person
    Article.delete_all
    a1 = fast_create(TextileArticle, :name => 'test article 1', :profile_id => profile.id)
    a2 = fast_create(TextileArticle, :name => 'test article 2', :profile_id => profile.id)
    a3 = fast_create(TextileArticle, :name => 'test article 3', :profile_id => profile.id, :parent_id => a2.id)

    block = DisplayContentBlock.new
    box = mock()
    box.stubs(:owner).returns(profile)
    block.stubs(:box).returns(box)
    assert_equal [], [a3] - block.articles_of_parent(a2)
    assert_equal [], block.articles_of_parent(a2) - [a3]
  end

  should "return all root articles from environment" do
    profile = fast_create(Community, :name => 'my test community', :identifier => 'mytestcommunity')
    environment = Environment.default
    Article.delete_all
    a1 = fast_create(TextileArticle, :name => 'test article 1', :profile_id => profile.id)
    a2 = fast_create(TextileArticle, :name => 'test article 2', :profile_id => profile.id)
    a3 = fast_create(TextileArticle, :name => 'test article 3', :profile_id => profile.id, :parent_id => a2.id)

    block = DisplayContentBlock.new
    box = mock()
    block.stubs(:box).returns(box)
    box.stubs(:owner).returns(environment)
    environment.stubs(:portal_community).returns(profile)

    assert_equal [], [a1, a2] - block.articles_of_parent
    assert_equal [], block.articles_of_parent - [a1, a2]
  end

  should "return all children of an articles's portal community of environment" do
    profile = fast_create(Community, :name => 'my test community', :identifier => 'mytestcommunity')
    environment = Environment.default
    Article.delete_all
    a1 = fast_create(TextileArticle, :name => 'test article 1', :profile_id => profile.id)
    a2 = fast_create(TextileArticle, :name => 'test article 2', :profile_id => profile.id)
    a3 = fast_create(TextileArticle, :name => 'test article 3', :profile_id => profile.id, :parent_id => a2.id)

    block = DisplayContentBlock.new
    box = mock()
    block.stubs(:box).returns(box)
    box.stubs(:owner).returns(environment)
    environment.stubs(:portal_community).returns(profile)

    assert_equal [], [a3] - block.articles_of_parent(a2)
    assert_equal [], block.articles_of_parent(a2) - [a3]
  end

  should "return an empty array if environment there is no portal community defined" do
    environment = Environment.default

    block = DisplayContentBlock.new
    box = mock()
    block.stubs(:box).returns(box)
    box.stubs(:owner).returns(environment)

    assert_equal [], block.articles_of_parent()
  end

  INVALID_KIND_OF_ARTICLE.map do |invalid_article|

    define_method "test_should_not_return_#{invalid_article.name}_articles_in_articles_of_parent_method" do
      profile = create_user('testuser').person
      Article.delete_all
      a1 = fast_create(invalid_article, :name => 'test article 1', :profile_id => profile.id)
      a2 = fast_create(VALID_KIND_OF_ARTICLE.first, :name => 'test article 2', :profile_id => profile.id)
 
      block = DisplayContentBlock.new
      box = mock()
      box.stubs(:owner).returns(profile)
      block.stubs(:box).returns(box)
      assert_equal [], [a2] - block.articles_of_parent
      assert_equal [], block.articles_of_parent - [a2]
    end
  
  end

  VALID_KIND_OF_ARTICLE.map do |valid_article|

    define_method "test_should_return_#{valid_article.name}_articles_in_articles_of_parent_method" do
      profile = create_user('testuser').person
      Article.delete_all
      a1 = fast_create(valid_article, :name => 'test article 1', :profile_id => profile.id)
      a2 = fast_create(INVALID_KIND_OF_ARTICLE.first, :name => 'test article 2', :profile_id => profile.id)
 
      block = DisplayContentBlock.new
      box = mock()
      box.stubs(:owner).returns(profile)
      block.stubs(:box).returns(box)
      assert_equal [a1], block.articles_of_parent
    end
  
  end

  should 'list links for all articles title defined in nodes' do
    profile = create_user('testuser').person
    Article.delete_all
    a1 = fast_create(TextArticle, :name => 'test article 1', :profile_id => profile.id)
    a2 = fast_create(TextArticle, :name => 'test article 2', :profile_id => profile.id)

    block = DisplayContentBlock.new
    block.nodes = [a1.id, a2.id]
    box = mock()
    block.stubs(:box).returns(box)
    box.stubs(:owner).returns(profile)
   
    assert_match /.*<a.*>#{a1.title}<\/a>/, block.content
    assert_match /.*<a.*>#{a2.title}<\/a>/, block.content
  end

  should 'list content for all articles lead defined in nodes' do
    profile = create_user('testuser').person
    Article.delete_all
    a1 = fast_create(TextArticle, :name => 'test article 1', :profile_id => profile.id, :abstract => 'abstract article 1')
    a2 = fast_create(TextArticle, :name => 'test article 2', :profile_id => profile.id, :abstract => 'abstract article 2')

    block = DisplayContentBlock.new
    block.chosen_attributes = ['abstract']
    block.nodes = [a1.id, a2.id]
    box = mock()
    block.stubs(:box).returns(box)
    box.stubs(:owner).returns(profile)
   
    assert_match /<div class="lead">#{a1.lead}<\/div>/, block.content
    assert_match /<div class="lead">#{a2.lead}<\/div>/, block.content
  end

  should 'not crash when referenced article is removed' do
    profile = create_user('testuser').person
    a1 = fast_create(TextArticle, :name => 'test article 1', :profile_id => profile.id)

    block = DisplayContentBlock.new
    block.nodes = [a1.id]
    box = mock()
    block.stubs(:box).returns(box)
    box.stubs(:owner).returns(profile)
   
    Article.delete_all
    assert_match /<ul><\/ul>/, block.content
  end

  should 'url_params return myprofile url params if the owner is a profile' do
    profile = create_user('testuser').person
    block = DisplayContentBlock.new
    block.box = profile.boxes.first
    block.save!
   
    params = {:block_id => block.id}
    params[:controller] = "display_content_plugin_myprofile"
    params[:profile] = profile.identifier
    assert_equal params, block.url_params
  end

  should 'url_params return admin url params if the owner is an environment' do
    environment = Environment.default
    block = DisplayContentBlock.new
    block.box = environment.boxes.first
    block.save!
   
    params = {:block_id => block.id}
    params[:controller] = "display_content_plugin_admin"
    assert_equal params, block.url_params
  end

  should 'show title if defined by user' do
    profile = create_user('testuser').person
    a = fast_create(TextArticle, :name => 'test article 1', :profile_id => profile.id)

    block = DisplayContentBlock.new
    block.nodes = [a.id]
    block.chosen_attributes = ['title']
    box = mock()
    block.stubs(:box).returns(box)
    box.stubs(:owner).returns(profile)
   
    assert_match /.*<a.*>#{a.title}<\/a>/, block.content
  end

  should 'show abstract if defined by user' do
    profile = create_user('testuser').person
    a = fast_create(TextArticle, :name => 'test article 1', :profile_id => profile.id, :abstract => 'some abstract')

    block = DisplayContentBlock.new
    block.nodes = [a.id]
    block.chosen_attributes = ['abstract']
    box = mock()
    block.stubs(:box).returns(box)
    box.stubs(:owner).returns(profile)
   
    assert_match /#{a.abstract}/, block.content
  end

  should 'show body if defined by user' do
    profile = create_user('testuser').person
    a = fast_create(TextArticle, :name => 'test article 1', :profile_id => profile.id, :body => 'some body')

    block = DisplayContentBlock.new
    block.nodes = [a.id]
    block.chosen_attributes = ['body']
    box = mock()
    block.stubs(:box).returns(box)
    box.stubs(:owner).returns(profile)
   
    assert_match /#{a.body}/, block.content
  end

  should 'display_attribute be true for title by default' do
    profile = create_user('testuser').person

    block = DisplayContentBlock.new
   
    assert block.display_attribute?('title')
  end

  should 'display_attribute be true if the attribute was chosen' do
    profile = create_user('testuser').person

    block = DisplayContentBlock.new
    block.chosen_attributes = ['body']
   
    assert block.display_attribute?('body')
  end

end
