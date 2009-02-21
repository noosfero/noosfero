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

  should 'list subitems as HTML content' do
    p = create_user('testuser').person
    f = Folder.create!(:profile => p, :name => 'f')
    f.children.create!(:profile => p, :name => 'onearticle')
    f.children.create!(:profile => p, :name => 'otherarticle')
    f.reload

    assert_tag_in_string f.to_html, :tag => 'td', :descendant => { :tag => 'a', :attributes => { :href => /.*\/testuser\/f\/onearticle(\?|$)/ } }, :content => /onearticle/
    assert_tag_in_string f.to_html, :tag => 'td', :descendant => { :tag => 'a', :attributes => { :href => /.*\/testuser\/f\/otherarticle(\?|$)/ } }, :content => /otherarticle/
  end

  should 'explictly advise if empty' do
    p = create_user('testuser').person
    f = Folder.create!(:profile => p, :name => 'f')
    assert_tag_in_string f.to_html, :content => '(empty folder)'
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

end
