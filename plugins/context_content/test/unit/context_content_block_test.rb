require 'test_helper'

class ContextContentBlockTest < ActiveSupport::TestCase

  def setup
    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([])
    @block = ContextContentPlugin::ContextContentBlock.create!
    @block.types = ['TinyMceArticle']
  end

  should 'describe itself' do
    assert_not_equal Block.description, ContextContentPlugin::ContextContentBlock.description
  end

  should 'has a help' do
    assert @block.help
  end

  should 'return nothing if page is nil' do
    assert_equal nil, @block.contents(nil)
  end

  should 'render nothing if it has no content to show' do
    assert_equal '', instance_eval(&@block.content)
  end

  should 'render context content block view' do
    @page = fast_create(Folder)
    article = fast_create(TinyMceArticle, :parent_id => @page.id)
    expects(:block_title).with(@block.title).returns('').once
    expects(:content_tag).returns('').once
    expects(:render).with(:file => 'blocks/context_content', :locals => {:block => @block, :contents => [article]})
    instance_eval(&@block.content)
  end

  should 'return children of page' do
    folder = fast_create(Folder)
    article = fast_create(TinyMceArticle, :parent_id => folder.id)
    assert_equal [article], @block.contents(folder)
  end

  should 'limit number of children to display' do
    @block.limit = 2
    folder = fast_create(Folder)
    article1 = fast_create(TinyMceArticle, :parent_id => folder.id)
    article2 = fast_create(TinyMceArticle, :parent_id => folder.id)
    article3 = fast_create(TinyMceArticle, :parent_id => folder.id)
    assert_equal 2, @block.contents(folder).length
  end

  should 'show contents for next page' do
    @block.limit = 2
    folder = fast_create(Folder)
    article1 = fast_create(TinyMceArticle, :name => 'article 1', :parent_id => folder.id)
    article2 = fast_create(TinyMceArticle, :name => 'article 2', :parent_id => folder.id)
    article3 = fast_create(TinyMceArticle, :name => 'article 3', :parent_id => folder.id)
    assert_equal [article3], @block.contents(folder, 2)
  end

  should 'show parent contents for next page' do
    @block.limit = 2
    folder = fast_create(Folder)
    article1 = fast_create(TinyMceArticle, :name => 'article 1', :parent_id => folder.id)
    article2 = fast_create(TinyMceArticle, :name => 'article 2', :parent_id => folder.id)
    article3 = fast_create(TinyMceArticle, :name => 'article 3', :parent_id => folder.id)
    assert_equal [article3], @block.contents(article1, 2)
  end

  should 'return parent children if page has no children' do
    folder = fast_create(Folder)
    article = fast_create(TinyMceArticle, :parent_id => folder.id)
    assert_equal [article], @block.contents(article)
  end

  should 'do not return parent children if show_parent_content is false' do
    @block.show_parent_content = false
    folder = fast_create(Folder)
    article = fast_create(TinyMceArticle, :parent_id => folder.id)
    assert_equal [], @block.contents(article)
  end

  should 'return nil if a page has no parent' do
    folder = fast_create(Folder)
    assert_equal nil, @block.contents(folder)
  end

  should 'return available content types with checked types first' do
    @block.types = ['TinyMceArticle', 'Folder']
    assert_equal [TinyMceArticle, Folder, UploadedFile, Event, TextileArticle, RawHTMLArticle, Blog, Forum, Gallery, RssFeed], @block.available_content_types
  end

  should 'return available content types' do
    @block.types = []
    assert_equal [UploadedFile, Event, TinyMceArticle, TextileArticle, RawHTMLArticle, Folder, Blog, Forum, Gallery, RssFeed], @block.available_content_types
  end

  should 'return first 2 content types' do
    assert_equal 2, @block.first_content_types.length
  end

  should 'return all but first 2 content types' do
    assert_equal @block.available_content_types.length - 2, @block.more_content_types.length
  end

  should 'return 2 as default value for first_types_count' do
    assert_equal 2, @block.first_types_count
  end

  should 'return types length if it has more than 2 selected types' do
    @block.types = ['UploadedFile', 'Event', 'Folder']
    assert_equal 3, @block.first_types_count
  end

  should 'return selected types at first_content_types' do
    @block.types = ['UploadedFile', 'Event', 'Folder']
    assert_equal [UploadedFile, Event, Folder], @block.first_content_types
    assert_equal @block.available_content_types - [UploadedFile, Event, Folder], @block.more_content_types
  end

  should 'include plugin content at available content types' do
    class SomePluginContent;end
    class SomePlugin; def content_types; SomePluginContent end end
    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([SomePlugin.new])

    @block.types = []
    assert_equal [UploadedFile, Event, TinyMceArticle, TextileArticle, RawHTMLArticle, Folder, Blog, Forum, Gallery, RssFeed, SomePluginContent], @block.available_content_types
  end

  should 'display thumbnail for image content' do
    content = UploadedFile.new(:uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'))
    content = FilePresenter.for(content)
    expects(:image_tag).once
    instance_eval(&@block.content_image(content))
  end

  should 'display div as content image for content that is not a image' do
    content = fast_create(Folder)
    content = FilePresenter.for(content)
    expects(:content_tag).once
    instance_eval(&@block.content_image(content))
  end

  should 'display div with extension class for uploaded file that is not a image' do
    content = UploadedFile.new(:uploaded_data => fixture_file_upload('/files/test.txt', 'text/plain'))
    content = FilePresenter.for(content)
    expects(:content_tag).with('div', '', :class => "context-icon icon-text icon-text-plain extension-txt").once
    instance_eval(&@block.content_image(content))
  end

  should 'do not display pagination links if page is nil' do
    @page = nil
    assert_equal '', instance_eval(&@block.footer)
  end

  should 'do not display pagination links if it has until one page' do
    assert_equal '', instance_eval(&@block.footer)
  end

  should 'display pagination links if it has more than one page' do
    @block.limit = 2
    @page = fast_create(Folder)
    article1 = fast_create(TinyMceArticle, :parent_id => @page.id)
    article2 = fast_create(TinyMceArticle, :parent_id => @page.id)
    article3 = fast_create(TinyMceArticle, :parent_id => @page.id)
    expects(:content_tag).once
    expects(:render).with(has_entry(:partial => 'blocks/more'))
    instance_eval(&@block.footer)
  end

  should 'return box owner on profile method call' do
    profile = fast_create(Community)
    box = Box.create!(:owner => profile)
    block = ContextContentPlugin::ContextContentBlock.create!(:box_id => box.id)
    assert_equal profile, block.profile
  end

  should 'not be cacheable' do
    assert !@block.cacheable?
  end

end
