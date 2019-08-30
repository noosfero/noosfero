require "test_helper"

class ContextContentBlockTest < ActiveSupport::TestCase
  def setup
    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([])
    @block = ContextContentPlugin::ContextContentBlock.create!
    @block.types = ["TextArticle"]
  end

  should "describe itself" do
    assert_not_equal Block.description, ContextContentPlugin::ContextContentBlock.description
  end

  should "has a help" do
    assert @block.help
  end

  should "return nothing if page is nil" do
    assert_nil @block.contents(nil)
  end

  should "return children of page" do
    folder = fast_create(Folder)
    article = fast_create(TextArticle, parent_id: folder.id)
    assert_equal [article], @block.contents(folder)
  end

  should "return parent name of the contents" do
    folder = fast_create(Folder, name: " New Folder")
    article = fast_create(TextArticle, parent_id: folder.id)
    assert_equal folder.name, @block.parent_title([article])
  end

  should "return no parent name if there is no content" do
    assert_nil @block.parent_title([])
  end

  should "limit number of children to display" do
    @block.limit = 2
    folder = fast_create(Folder)
    article1 = fast_create(TextArticle, parent_id: folder.id)
    article2 = fast_create(TextArticle, parent_id: folder.id)
    article3 = fast_create(TextArticle, parent_id: folder.id)
    assert_equal 2, @block.contents(folder).length
  end

  should "show contents for next page" do
    @block.limit = 2
    folder = fast_create(Folder)
    article1 = fast_create(TextArticle, name: "article 1", parent_id: folder.id)
    article2 = fast_create(TextArticle, name: "article 2", parent_id: folder.id)
    article3 = fast_create(TextArticle, name: "article 3", parent_id: folder.id)
    assert_equal [article3], @block.contents(folder, 2)
  end

  should "show parent contents for next page" do
    @block.limit = 2
    folder = fast_create(Folder)
    article1 = fast_create(TextArticle, name: "article 1", parent_id: folder.id)
    article2 = fast_create(TextArticle, name: "article 2", parent_id: folder.id)
    article3 = fast_create(TextArticle, name: "article 3", parent_id: folder.id)
    assert_equal [article3], @block.contents(article1, 2)
  end

  should "return parent children if page has no children" do
    folder = fast_create(Folder)
    article = fast_create(TextArticle, parent_id: folder.id)
    assert_equal [article], @block.contents(article)
  end

  should "do not return parent children if show_parent_content is false" do
    @block.show_parent_content = false
    folder = fast_create(Folder)
    article = fast_create(TextArticle, parent_id: folder.id)
    assert_equal [], @block.contents(article)
  end

  should "return nil if a page has no parent" do
    folder = fast_create(Folder)
    assert_nil @block.contents(folder)
  end

  should "return available content types with checked types first" do
    @block.types = ["TextArticle", "Folder"]
    assert_equal [TextArticle, Folder, UploadedFile, Event, Blog, Forum, Gallery, RssFeed], @block.available_content_types
  end

  should "return available content types" do
    @block.types = []
    assert_equal [UploadedFile, Event, TextArticle, Folder, Blog, Forum, Gallery, RssFeed], @block.available_content_types
  end

  should "return first 2 content types" do
    assert_equal 2, @block.first_content_types.length
  end

  should "return all but first 2 content types" do
    assert_equal @block.available_content_types.length - 2, @block.more_content_types.length
  end

  should "return 2 as default value for first_types_count" do
    assert_equal 2, @block.first_types_count
  end

  should "return types length if it has more than 2 selected types" do
    @block.types = ["UploadedFile", "Event", "Folder"]
    assert_equal 3, @block.first_types_count
  end

  should "return selected types at first_content_types" do
    @block.types = ["UploadedFile", "Event", "Folder"]
    assert_equal [UploadedFile, Event, Folder], @block.first_content_types
    assert_equal @block.available_content_types - [UploadedFile, Event, Folder], @block.more_content_types
  end

  should "include plugin content at available content types" do
    class SomePluginContent; end
    class SomePlugin; def content_types; SomePluginContent end end
    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([SomePlugin.new])

    @block.types = []
    assert_equal [UploadedFile, Event, TextArticle, Folder, Blog, Forum, Gallery, RssFeed, SomePluginContent], @block.available_content_types
  end

  should "return box owner on profile method call" do
    profile = fast_create(Community)
    box = Box.create!(owner: profile)
    block = ContextContentPlugin::ContextContentBlock.create!(box_id: box.id)
    assert_equal profile, block.profile
  end

  should "not be cacheable" do
    refute @block.cacheable?
  end
end

require "boxes_helper"

class ContextContentBlockViewTest < ActionView::TestCase
  include BoxesHelper

  def setup
    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([])
    @block = ContextContentPlugin::ContextContentBlock.create!
    @block.types = ["TextArticle"]
  end

  should "render nothing if it has no content to show" do
    assert_equal "\n", render_block_content(@block)
  end

  should "render context content block view" do
    @page = fast_create(Folder)
    article = fast_create(TextArticle, parent_id: @page.id)
    contents = [article]
    @block.use_parent_title = true

    article.expects(:view_url).returns("http://test.noosfero.plugins")
    @block.expects(:contents).with(@page).returns(contents)
    @block.expects(:parent_title).with(contents).returns(@page.name)
    ActionView::Base.any_instance.expects(:block_title).with(@page.name, @block.subtitle).returns("")

    render_block_content(@block)
  end

  should "do not display pagination links if page is nil" do
    @page = nil

    assert_equal "\n", render_block_content(@block)
  end

  should "do not display pagination links if it has until one page" do
    assert_equal "\n", render_block_content(@block)
  end

  should "display pagination links if it has more than one page" do
    @block.limit = 2
    @page = fast_create(Folder)
    article1 = fast_create(TextArticle, parent_id: @page.id)
    article2 = fast_create(TextArticle, parent_id: @page.id)
    article3 = fast_create(TextArticle, parent_id: @page.id)
    contents = [article1, article2, article3]
    contents.each do |article|
      article.expects(:view_url).returns("http://test.noosfero.plugins")
    end

    ActionView::Base.any_instance.expects(:block_title).returns("")
    @block.expects(:contents).with(@page).returns(contents)

    render_block_content(@block)
  end
end
