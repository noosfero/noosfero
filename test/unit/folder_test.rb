require File.dirname(__FILE__) + '/../test_helper'

class FolderTest < ActiveSupport::TestCase

  should 'be an article' do
    assert_kind_of Article, Folder.new
  end

  should 'provide proper description' do
    assert_kind_of String, Folder.description
  end

  should 'provide proper short description' do
    assert_kind_of String, Folder.short_description
  end

  should 'provide own icon name' do
    assert_not_equal Article.new.icon_name, Folder.new.icon_name
  end

  should 'show text body in HTML content' do
    p = create_user('testuser').person
    f = Folder.create!(:name => 'f', :profile => p, :body => 'this-is-the-text')

    assert_match(/this-is-the-text/, f.to_html)
  end

  should 'identify as folder' do
    assert Folder.new.folder?, 'folder must identity itself as folder'
  end

  should 'can display hits' do
    profile = create_user('testuser').person
    a = Folder.create!(:name => 'Test article', :profile => profile)
    assert_equal false, a.can_display_hits?
  end

  should 'be viewed as image gallery' do
    p = create_user('test_user').person
    f = Folder.create!(:name => 'Test folder', :profile => p)
    f.view_as = 'image_gallery'; f.save!
    f.reload

    assert_equal 'image_gallery', f.view_as
  end

  should 'not allow view as bogus' do
    p = create_user('test_user').person
    f = Folder.create!(:name => 'Test folder', :profile => p)
    f.view_as = 'bogus'
    assert !f.save
  end

  should 'view as folder by default' do
    p = create_user('test_user').person
    f = Folder.create!(:name => 'Test folder', :profile => p)
    f.expects(:folder)
    f.to_html

    assert_equal 'folder', f.view_as
  end

  should 'have images that are only images or other folders' do
    p = create_user('test_user').person
    f = Folder.create!(:name => 'Test folder', :profile => p)
    file = UploadedFile.create!(:uploaded_data => fixture_file_upload('/files/test.txt', 'text/plain'), :parent => f, :profile => p)
    image = UploadedFile.create!(:uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'), :parent => f, :profile => p)
    folder = Folder.create!(:name => 'child test folder', :parent => f, :profile => p)

    assert_equivalent [folder, image], f.images
  end

  should 'bring folders first in alpha order in images listing' do
    p = create_user('test_user').person
    f = Folder.create!(:name => 'Test folder', :profile => p)
    folder1 = Folder.create!(:name => 'child test folder 1', :parent => f, :profile => p)
    image = UploadedFile.create!(:uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'), :parent => f, :profile => p)
    folder2 = Folder.create!(:name => 'child test folder 2', :parent => f, :profile => p)
    folder3 = Folder.create!(:name => 'another child test folder', :parent => f, :profile => p)

    assert_equal [folder3.id, folder1.id, folder2.id, image.id], f.images.map(&:id)
  end

  should 'images support pagination' do
    p = create_user('test_user').person
    f = Folder.create!(:name => 'Test folder', :profile => p)
    folder = Folder.create!(:name => 'child test folder', :parent => f, :profile => p)
    image = UploadedFile.create!(:uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'), :parent => f, :profile => p)

    assert_equal [image], f.images.paginate(:page => 2, :per_page => 1)
  end

  should 'return newest text articles as news' do
    c = Community.create!(:name => 'test_com')
    folder = Folder.create!(:name => 'folder', :profile => c)
    f = Folder.create!(:name => 'folder', :profile => c, :parent => folder)
    u = UploadedFile.create!(:profile => c, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'), :parent => folder)
    older_t = TinyMceArticle.create!(:name => 'old news', :profile => c, :parent => folder)
    t = TinyMceArticle.create!(:name => 'news', :profile => c, :parent => folder)
    t_in_f = TinyMceArticle.create!(:name => 'news', :profile => c, :parent => f)

    assert_equal [t], folder.news(1)
  end

  should 'not return highlighted news when not asked' do
    c = Community.create!(:name => 'test_com')
    folder = Folder.create!(:name => 'folder', :profile => c)
    highlighted_t = TinyMceArticle.create!(:name => 'high news', :profile => c, :highlighted => true, :parent => folder)
    t = TinyMceArticle.create!(:name => 'news', :profile => c, :parent => folder)

    assert_equal [t].map(&:slug), folder.news(2).map(&:slug)
  end

  should 'return highlighted news when asked' do
    c = Community.create!(:name => 'test_com')
    folder = Folder.create!(:name => 'folder', :profile => c)
    highlighted_t = TinyMceArticle.create!(:name => 'high news', :profile => c, :highlighted => true, :parent => folder)
    t = TinyMceArticle.create!(:name => 'news', :profile => c, :parent => folder)

    assert_equal [highlighted_t].map(&:slug), folder.news(2, true).map(&:slug)
  end

  should 'return published images as images' do
    p = create_user('test_user').person
    i = UploadedFile.create!(:profile => p, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'))

    c = Community.create!(:name => 'test_com')
    folder = Folder.create!(:name => 'folder', :profile => c)
    pi = PublishedArticle.create!(:profile => c, :reference_article => i, :parent => folder)

    assert_includes folder.images(true), pi
  end
end
