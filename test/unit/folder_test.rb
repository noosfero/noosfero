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

    assert_match(/<li><a href=".*\/testuser\/f\/onearticle">onearticle<\/a><\/li>/, f.to_html)
    assert_match(/<li><a href=".*\/testuser\/f\/otherarticle">otherarticle<\/a><\/li>/, f.to_html)
  end

  should 'show text body in HTML content' do
    p = create_user('testuser').person
    f = Folder.create!(:name => 'f', :profile => p, :body => 'this-is-the-text')

    assert_match(/this-is-the-text/, f.to_html)
  end

  should 'identify as folder' do
    assert Folder.new.folder?, 'folder must identity itself as folder'
  end

end
