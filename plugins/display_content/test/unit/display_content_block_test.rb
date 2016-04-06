require_relative '../test_helper'
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

  should 'not expand nodes if there is no holder' do
    Article.delete_all
    a1 = fast_create(TextArticle, :name => 'test article 1', :profile_id => 1)

    checked_articles= {a1.id => true}
    block = DisplayContentBlock.new
    block.stubs(:holder).returns(nil)
    block.checked_nodes= checked_articles
    a1.delete
    block.save!
    assert_equal [a1.id], block.nodes
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

  should "save selected folders and articles" do
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

    assert_equivalent [a1.id, a2.id, f1.id], block.nodes
  end

  should "save selected articles and blogs" do
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

    assert_equivalent [a1.id, a2.id, b1.id, b2.id], block.nodes
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

  should 'Event be saved as node' do
    profile = create_user('testuser').person
    Article.delete_all
    a1 = fast_create(TextArticle, :name => 'test article 1', :profile_id => profile.id)
    a2 = fast_create(TextArticle, :name => 'test article 2', :profile_id => profile.id)
    a3 = fast_create(Event, :name => 'test article 3', :profile_id => profile.id)

    checked_articles= {a1.id => true, a2.id => true, a3.id => false}
    block = DisplayContentBlock.new
    block.stubs(:holder).returns(profile)
    block.checked_nodes= checked_articles
    assert_equivalent [a1.id, a2.id, a3.id], block.nodes
  end

  should 'Folder be saved as node' do
    profile = create_user('testuser').person
    Article.delete_all
    a1 = fast_create(TextArticle, :name => 'test article 1', :profile_id => profile.id)
    a2 = fast_create(TextArticle, :name => 'test article 2', :profile_id => profile.id)
    a3 = fast_create(Folder, :name => 'test article 3', :profile_id => profile.id)

    checked_articles= {a1.id => true, a2.id => true, a3.id => false}
    block = DisplayContentBlock.new
    block.stubs(:holder).returns(profile)
    block.checked_nodes= checked_articles
    assert_equivalent [a1.id, a2.id, a3.id], block.nodes
  end

  should 'Forum be saved as node' do
    profile = create_user('testuser').person
    Article.delete_all
    a1 = fast_create(TextArticle, :name => 'test article 1', :profile_id => profile.id)
    a2 = fast_create(TextArticle, :name => 'test article 2', :profile_id => profile.id)
    a3 = fast_create(Forum, :name => 'test article 3', :profile_id => profile.id)

    checked_articles= {a1.id => true, a2.id => true, a3.id => false}
    block = DisplayContentBlock.new
    block.stubs(:holder).returns(profile)
    block.checked_nodes= checked_articles
    assert_equivalent [a1.id, a2.id, a3.id], block.nodes
  end

  should 'Blog be saved as node' do
    profile = create_user('testuser').person
    Article.delete_all
    a1 = fast_create(TextArticle, :name => 'test article 1', :profile_id => profile.id)
    a2 = fast_create(TextArticle, :name => 'test article 2', :profile_id => profile.id)
    a3 = fast_create(Blog, :name => 'test article 3', :profile_id => profile.id)

    checked_articles= {a1.id => true, a2.id => true, a3.id => false}
    block = DisplayContentBlock.new
    block.stubs(:holder).returns(profile)
    block.checked_nodes= checked_articles
    assert_equivalent [a1.id, a2.id, a3.id], block.nodes
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
    box.stubs(:environment).returns(Environment.default)
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
    box.stubs(:environment).returns(Environment.default)
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
    box.stubs(:environment).returns(Environment.default)
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
    box.stubs(:environment).returns(Environment.default)
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
    box.stubs(:environment).returns(Environment.default)

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
      box.stubs(:environment).returns(Environment.default)
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
      box.stubs(:environment).returns(Environment.default)
      block.stubs(:box).returns(box)
      assert_equal [a1], block.articles_of_parent
    end

  end

  should 'list links for all articles title defined in nodes' do
    profile = create_user('testuser').person
    Article.delete_all
    a1 = fast_create(TextileArticle, :name => 'test article 1', :profile_id => profile.id)
    a2 = fast_create(TextileArticle, :name => 'test article 2', :profile_id => profile.id)

    block = DisplayContentBlock.new
    block.sections = [{:value => 'title', :checked => true}]
    block.nodes = [a1.id, a2.id]
    box = mock()
    block.stubs(:box).returns(box)
    box.stubs(:owner).returns(profile)

    assert_match /.*<a.*>#{a1.title}<\/a>/, instance_eval(&block.content)
    assert_match /.*<a.*>#{a2.title}<\/a>/, instance_eval(&block.content)
  end

  should 'list content for all articles lead defined in nodes' do
    profile = create_user('testuser').person
    Article.delete_all
    a1 = fast_create(TinyMceArticle, :name => 'test article 1', :profile_id => profile.id, :abstract => 'abstract article 1')
    a2 = fast_create(TinyMceArticle, :name => 'test article 2', :profile_id => profile.id, :abstract => 'abstract article 2')

    block = DisplayContentBlock.new
    block.sections = [{:value => 'abstract', :checked => true}]
    block.nodes = [a1.id, a2.id]
    box = mock()
    block.stubs(:box).returns(box)
    box.stubs(:owner).returns(profile)

    assert_match /<div class="lead">#{a1.lead}<\/div>/, instance_eval(&block.content)
    assert_match /<div class="lead">#{a2.lead}<\/div>/, instance_eval(&block.content)
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
    assert_match /<ul><\/ul>/, instance_eval(&block.content)
  end
  include ActionView::Helpers
  include Rails.application.routes.url_helpers

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
    a = fast_create(TextileArticle, :name => 'test article 1', :profile_id => profile.id)

    block = DisplayContentBlock.new
    block.nodes = [a.id]
    block.sections = [{:value => 'title', :checked => true}]
    box = mock()
    block.stubs(:box).returns(box)
    box.stubs(:owner).returns(profile)

    assert_match /.*<a.*>#{a.title}<\/a>/, instance_eval(&block.content)
  end

  should 'show abstract if defined by user' do
    profile = create_user('testuser').person
    a = fast_create(TextileArticle, :name => 'test article 1', :profile_id => profile.id, :abstract => 'some abstract')

    block = DisplayContentBlock.new
    block.nodes = [a.id]
    block.sections = [{:value => 'abstract', :checked => true}]
    box = mock()
    block.stubs(:box).returns(box)
    box.stubs(:owner).returns(profile)

    assert_match /#{a.abstract}/, instance_eval(&block.content)
  end

  should 'show body if defined by user' do
    profile = create_user('testuser').person
    a = fast_create(TextileArticle, :name => 'test article 1', :profile_id => profile.id, :body => 'some body')

    block = DisplayContentBlock.new
    block.nodes = [a.id]
    block.sections = [{:value => 'body', :checked => true}]
    box = mock()
    block.stubs(:box).returns(box)
    box.stubs(:owner).returns(profile)

    assert_match /#{a.body}/, instance_eval(&block.content)
  end

  should 'display_attribute be true for title by default' do
    profile = create_user('testuser').person

    block = DisplayContentBlock.new

    assert block.display_section?({:value => 'title', :checked => true})
  end

  should 'display_attribute be true if the attribute was chosen' do
    profile = create_user('testuser').person

    block = DisplayContentBlock.new

    section = {:value => 'body', :checked => true}
    block.sections = [section]

    assert block.display_section?(section)
  end

  should 'display_attribute be true for publish date by default' do
    profile = create_user('testuser').person

    block = DisplayContentBlock.new

    assert block.display_section?({:value => 'publish_date', :checked => true})
  end

  should 'show publishd date if defined by user' do
    profile = create_user('testuser').person
    a = fast_create(TextArticle, :name => 'test article 1', :profile_id => profile.id, :body => 'some body')

    block = DisplayContentBlock.new
    block.nodes = [a.id]
    block.sections = [{:value => 'publish_date', :checked => true}]
    box = mock()
    block.stubs(:box).returns(box)
    box.stubs(:owner).returns(profile)

    assert_match /#{a.published_at}/, instance_eval(&block.content)
  end

  should 'do not save children if a folder is checked' do
    profile = create_user('testuser').person
    Article.delete_all
    f1 = fast_create(Folder, :name => 'test folder 1', :profile_id => profile.id)
    a1 = fast_create(TextileArticle, :name => 'test article 1', :profile_id => profile.id, :parent_id => f1.id)
    a2 = fast_create(TextileArticle, :name => 'test article 2', :profile_id => profile.id, :parent_id => f1.id)
    a3 = fast_create(TextileArticle, :name => 'test article 3', :profile_id => profile.id, :parent_id => f1.id)

    checked_articles= {f1.id => true, a1.id => true, a2.id => true, a3.id => false}
    block = DisplayContentBlock.new
    block.stubs(:holder).returns(profile)
    block.checked_nodes= checked_articles
    block.save!
    assert_equivalent [f1.id], block.nodes
  end

  should 'save folder and children if display_folder_children is false' do
    profile = create_user('testuser').person
    Article.delete_all
    f1 = fast_create(Folder, :name => 'test folder 1', :profile_id => profile.id)
    a1 = fast_create(TextileArticle, :name => 'test article 1', :profile_id => profile.id, :parent_id => f1.id)
    a2 = fast_create(TextileArticle, :name => 'test article 2', :profile_id => profile.id, :parent_id => f1.id)
    a3 = fast_create(TextileArticle, :name => 'test article 3', :profile_id => profile.id, :parent_id => f1.id)

    checked_articles= {f1.id => true, a1.id => true, a2.id => true, a3.id => false}
    block = DisplayContentBlock.new
    block.display_folder_children = false
    block.stubs(:holder).returns(profile)
    block.checked_nodes= checked_articles
    block.save!
    assert_equivalent [f1.id, a1.id, a2.id, a3.id], block.nodes
  end

  should "test should return plugins articles in articles of parent method" do
    class PluginArticle < Article; end

    class Plugin1 < Noosfero::Plugin
      def content_types
        [PluginArticle]
      end
    end

    profile = create_user('testuser').person
    Article.delete_all
    a1 = fast_create(PluginArticle, :name => 'test article 1', :profile_id => profile.id)
    Noosfero::Plugin.stubs(:all).returns([Plugin1.name])
    env = fast_create(Environment)
    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([Plugin1.new])

    block = DisplayContentBlock.new
    box = mock()
    box.stubs(:owner).returns(profile)
    Noosfero::Plugin.stubs(:all).returns(['DisplayContentBlockTest::Plugin1'])
    box.stubs(:environment).returns(env)
    block.stubs(:box).returns(box)
    assert_equal [a1], block.articles_of_parent
  end

  should "the section display all available sections" do
    block = DisplayContentBlock.new
    assert_equivalent ['publish_date', 'abstract', 'body', 'image' ,'tags', 'title'], block.sections.map{|e|e[:value]}
  end

  should "the section display all available sections if the section value has only one key" do
    block = DisplayContentBlock.new
    block.sections = [{:value => 'abstract', :checked => true}]
    assert_equivalent ['publish_date', 'abstract', 'body', 'image' ,'tags', 'title'], block.sections.map{|e|e[:value]}
  end

  should 'return available content types with checked types first' do
    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([])
    block = DisplayContentBlock.create!
    block.types = ['TinyMceArticle']

    block.types = ['TinyMceArticle', 'Folder']
    assert_equivalent [TinyMceArticle, Folder, UploadedFile, Event, TextileArticle, RawHTMLArticle, Blog, Forum, Gallery, RssFeed], block.available_content_types
  end

  should 'return available content types' do
    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([])
    block = DisplayContentBlock.create!
    block.types = ['TinyMceArticle']
    block.types = []
    assert_equivalent [UploadedFile, Event, TinyMceArticle, TextileArticle, RawHTMLArticle, Folder, Blog, Forum, Gallery, RssFeed], block.available_content_types
  end

  should 'return first 2 content types' do
    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([])
    block = DisplayContentBlock.create!
    block.types = ['TinyMceArticle']
    assert_equal 2, block.first_content_types.length
  end

  should 'return all but first 2 content types' do
    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([])
    block = DisplayContentBlock.create!
    block.types = ['TinyMceArticle']
    assert_equal block.available_content_types.length - 2, block.more_content_types.length
  end

  should 'return 2 as default value for first_types_count' do
    block = DisplayContentBlock.create!
    block.types = ['TinyMceArticle']
    assert_equal 2, block.first_types_count
  end

  should 'return types length if it has more than 2 selected types' do
    block = DisplayContentBlock.create!
    block.types = ['UploadedFile', 'Event', 'Folder']
    assert_equal 3, block.first_types_count
  end

  should 'return selected types at first_content_types' do
    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([])
    block = DisplayContentBlock.create!
    block.types = ['UploadedFile', 'Event', 'Folder']
    assert_equal [UploadedFile, Event, Folder], block.first_content_types
    assert_equal block.available_content_types - [UploadedFile, Event, Folder], block.more_content_types
  end

  should 'include plugin content at available content types' do
    block = DisplayContentBlock.create!
    class SomePluginContent;end
    class SomePlugin; def content_types; SomePluginContent end end
    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([SomePlugin.new])

    block.types = []
    assert_equivalent [UploadedFile, Event, TinyMceArticle, TextileArticle, RawHTMLArticle, Folder, Blog, Forum, Gallery, RssFeed, SomePluginContent], block.available_content_types
  end

  should 'do not fail if a selected article was removed' do
    profile = create_user('testuser').person
    Article.delete_all
    f1 = fast_create(Folder, :name => 'test folder 1', :profile_id => profile.id)
    a1 = fast_create(TextileArticle, :name => 'test article 1', :profile_id => profile.id, :parent_id => f1.id)

    checked_articles= {a1.id => true}

    block = DisplayContentBlock.new
    block.stubs(:holder).returns(profile)
    block.checked_nodes= checked_articles
    a1.destroy
    assert_equal [], block.parent_nodes
  end

  should 'show articles in recent order' do
    profile = create_user('testuser').person
    Article.delete_all
    a1 = fast_create(TextileArticle, :name => 'test article 1', :profile_id => profile.id, :published_at => DateTime.current)
    a2 = fast_create(TextileArticle, :name => 'test article 2', :profile_id => profile.id, :published_at => (DateTime.current + 1))

    block = DisplayContentBlock.new
    block.sections = [{:value => 'title', :checked => true}]
    block.nodes = [a1.id, a2.id]
    box = mock()
    block.stubs(:box).returns(box)
    box.stubs(:owner).returns(profile)

    block.order_by_recent = true

    a1_index = instance_eval(&block.content).index(a1.name)
    a2_index = instance_eval(&block.content).index(a2.name)

    assert a2_index < a1_index
  end

  should 'show articles in oldest order' do
    profile = create_user('testuser').person
    Article.delete_all
    a1 = fast_create(TextileArticle, :name => 'test article 1', :profile_id => profile.id, :published_at => DateTime.current)
    a2 = fast_create(TextileArticle, :name => 'test article 2', :profile_id => profile.id, :published_at => (DateTime.current + 1))

    block = DisplayContentBlock.new
    block.sections = [{:value => 'title', :checked => true}]
    block.nodes = [a1.id, a2.id]
    box = mock()
    block.stubs(:box).returns(box)
    box.stubs(:owner).returns(profile)

    block.order_by_recent = false

    a1_index = instance_eval(&block.content).index(a1.name)
    a2_index = instance_eval(&block.content).index(a2.name)

    assert a1_index < a2_index
  end

  should 'show articles in recent order with limit option' do
    profile = create_user('testuser').person
    Article.delete_all
    a1 = fast_create(TextileArticle, :name => 'test article 1', :profile_id => profile.id, :published_at => DateTime.current)
    a2 = fast_create(TextileArticle, :name => 'test article 2', :profile_id => profile.id, :published_at => (DateTime.current + 1))

    block = DisplayContentBlock.new
    block.sections = [{:value => 'title', :checked => true}]
    block.display_folder_children = true
    box = mock()
    block.stubs(:box).returns(box)
    box.stubs(:owner).returns(profile)

    block.order_by_recent = true
    block.limit_to_show = 1

    a1_index = instance_eval(&block.content).index(a1.name)

    assert a1_index.nil?
  end

  should 'show only articles with current locale translation' do
    FastGettext.stubs(:locale).returns('pt')
    profile = create_user('testuser').person
    Article.delete_all

    en_article = fast_create(TextileArticle, :profile_id => profile.id, :name => 'en_article', :language => 'en')
    en_article2 = fast_create(TextileArticle, :profile_id => profile.id, :name => 'en_article 2', :language => 'en')

    pt_article = fast_create TextileArticle, profile_id: profile.id, name: 'pt_article', language: 'pt', translation_of_id: en_article.id

    block = DisplayContentBlock.new
    block.sections = [{:value => 'title', :checked => true}]
    block.content_with_translations = true
    block.limit_to_show = 2

    box = mock()
    block.stubs(:box).returns(box)
    box.stubs(:owner).returns(profile)

    assert_nil instance_eval(&block.content).index(en_article.name)
    assert_nil instance_eval(&block.content).index(en_article2.name)
    assert instance_eval(&block.content).index(pt_article.name).present?

    FastGettext.stubs(:locale).returns('en')

    assert instance_eval(&block.content).index(en_article.name)
    assert instance_eval(&block.content).index(en_article2.name)
    assert_nil instance_eval(&block.content).index(pt_article.name)
  end

  should 'replace article with its translation' do
    FastGettext.stubs(:locale).returns('pt')
    profile = create_user('testuser').person
    Article.delete_all

    en_article = fast_create(TextileArticle, :profile_id => profile.id, :name => 'en_article', :language => 'en')
    pt_article = fast_create(TextileArticle, :profile_id => profile.id, :name => 'pt_article', :language => 'pt', :translation_of_id => en_article)

    block = DisplayContentBlock.new
    block.sections = [{:value => 'title', :checked => true}]
    block.content_with_translations = true
    block.limit_to_show = 2

    box = mock()
    block.stubs(:box).returns(box)
    box.stubs(:owner).returns(profile)

    assert_nil instance_eval(&block.content).index(en_article.name)
    assert instance_eval(&block.content).index(pt_article.name).present?

    FastGettext.stubs(:locale).returns('en')

    assert instance_eval(&block.content).index(en_article.name).present?
    assert_nil instance_eval(&block.content).index(pt_article.name)
  end
end
