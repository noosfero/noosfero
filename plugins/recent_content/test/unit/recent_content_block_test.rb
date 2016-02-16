require_relative '../test_helper'
class RecentContentBlockTest < ActiveSupport::TestCase

  INVALID_KIND_OF_ARTICLE = [EnterpriseHomepage, RssFeed, UploadedFile, Gallery, Folder, Blog, Forum]
  VALID_KIND_OF_ARTICLE = [RawHTMLArticle, TextArticle, TextileArticle, TinyMceArticle]

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

    a1 = fast_create(TextileArticle, :name => 'article #1', :profile_id => profile.id, :parent_id => root.id, :created_at => Time.now - 2.days)
    a2 = fast_create(TextileArticle, :name => 'article #2', :profile_id => profile.id, :parent_id => root.id, :created_at => Time.now - 1.days)
    a3 = fast_create(TextileArticle, :name => 'article #3', :profile_id => profile.id, :parent_id => root.id, :created_at => Time.now)

    block = RecentContentBlock.new
    block.stubs(:holder).returns(profile)

    assert block.articles_of_folder(root,2) == [a3, a2]
    assert block.articles_of_folder(root,3) == [a3, a2, a1]
  end

end
