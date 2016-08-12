require_relative '../test_helper'
class RecentContentBlockTest < ActiveSupport::TestCase

  INVALID_KIND_OF_ARTICLE = [RssFeed, UploadedFile, Gallery, Folder, Blog, Forum]
  VALID_KIND_OF_ARTICLE = [TextArticle]

  should 'describe itself' do
    assert_not_equal Block.description, RecentContentBlock.description
  end

  should 'is editable' do
    block = RecentContentBlock.new
    assert block.editable?
  end

  should 'blog_picture be false by default' do
    block = RecentContentBlock.new
    refute block.show_blog_picture
  end

  should 'blog_picture is being stored and restored from database as true' do
    block = RecentContentBlock.new
    block.show_blog_picture = true
    block.save
    block.reload

    assert block.show_blog_picture
  end

  should 'blog_picture is being stored and restored from database as false' do
    block = RecentContentBlock.new
    block.show_blog_picture = false
    block.save
    block.reload

    refute block.show_blog_picture
  end

  should 'root be nil for new blocks' do
    block = RecentContentBlock.new

    assert block.root.nil?
  end

  should 'root be a Blog when it is configured for' do
    profile = create_user('testuser').person

    root = fast_create(Blog, :name => 'test-blog', :profile_id => profile.id)

    block = RecentContentBlock.new
    block.stubs(:holder).returns(profile)
    block.selected_folder = root.id

    assert block.root.id == root.id
  end

  should 'return last articles inside a folder' do
    profile = create_user('testuser').person

    Article.delete_all

    root = fast_create(Blog, :name => 'test-blog', :profile_id => profile.id)

    a1 = fast_create(TextArticle, :name => 'article #1', :profile_id => profile.id, :parent_id => root.id, :created_at => Time.now - 2.days)
    a2 = fast_create(TextArticle, :name => 'article #2', :profile_id => profile.id, :parent_id => root.id, :created_at => Time.now - 1.days)
    a3 = fast_create(TextArticle, :name => 'article #3', :profile_id => profile.id, :parent_id => root.id, :created_at => Time.now)

    block = RecentContentBlock.new
    block.stubs(:holder).returns(profile)

    assert block.articles_of_folder(root,2) == [a3, a2]
    assert block.articles_of_folder(root,3) == [a3, a2, a1]
  end

end

require 'boxes_helper'

class RecentContentBlockViewTest < ActionView::TestCase
  include BoxesHelper

  should 'show the alert when the block has no root' do
    block = RecentContentBlock.new

    block.expects(:root).returns(nil)

    content = render_block_content(block)

    assert_match /#{_('This is the recent content block. Please edit it to show the content you want.')}/, content
  end

  should 'show the title and the child titles when the block has a root and is set to title only mode' do
    profile = create_user('testuser').person

    root = fast_create(Blog, :name => 'test-blog', :profile_id => profile.id)

    block = RecentContentBlock.new
    block.stubs(:holder).returns(profile)
    block.selected_folder = root.id
    block.presentation_mode = 'title_only'

    ActionView::Base.any_instance.expects(:block_title).returns("Block Title")
    ActionView::Base.any_instance.stubs(:profile).returns(profile)

    content = render_block_content(block)

    assert_match /Block Title/, content
  end

  should 'show the title and the child titles and abstracts when the block has a root and is set to title and abstract mode' do
    profile = create_user('testuser').person

    root = fast_create(Blog, :name => 'test-blog', :profile_id => profile.id)

    block = RecentContentBlock.new
    block.stubs(:holder).returns(profile)
    block.selected_folder = root.id
    block.presentation_mode = 'title_and_abstract'

    ActionView::Base.any_instance.expects(:block_title).returns("Block Title")
    ActionView::Base.any_instance.stubs(:profile).returns(profile)

    content = render_block_content(block)

    assert_match /Block Title/, content
  end

  should 'show the title and the child full content when the block has a root and has no mode set' do
    profile = create_user('testuser').person

    root = fast_create(Blog, :name => 'test-blog', :profile_id => profile.id)

    block = RecentContentBlock.new
    block.stubs(:holder).returns(profile)
    block.selected_folder = root.id
    block.presentation_mode = ''

    ActionView::Base.any_instance.expects(:block_title).returns("Block Title")
    ActionView::Base.any_instance.stubs(:profile).returns(profile)

    content = render_block_content(block)

    assert_match /Block Title/, content
  end

  should 'return articles in api_content' do
    profile = create_user('testuser').person

    root = fast_create(Blog, name: 'test-blog', profile_id: profile.id)
    article = fast_create(TextArticle, parent_id: root.id, profile_id: profile.id)

    block = RecentContentBlock.new
    block.stubs(:holder).returns(profile)
    block.selected_folder = root.id
    block.presentation_mode = ''
    assert_equal [article.id], block.api_content['articles'].map {|a| a[:id]}
  end

  should 'parents return an empty array for environment without portal community' do
    environment = fast_create(Environment)
    block = RecentContentBlock.new
    box = mock()
    block.stubs(:box).returns(box)
    box.stubs(:owner).returns(environment)

    assert_nil environment.portal_community
    assert_equal [], block.parents
  end

end
