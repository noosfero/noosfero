require File.dirname(__FILE__) + '/../test_helper'

class FolderHelperTest < Test::Unit::TestCase

  include FolderHelper

  should 'display icon for articles' do
    art1 = mock; art1.expects(:icon_name).returns('icon1')
    art2 = mock; art2.expects(:icon_name).returns('icon2')

    File.expects(:exists?).with(File.join(RAILS_ROOT, 'public', 'images', 'icons-mime', 'icon1.png')).returns(true)
    File.expects(:exists?).with(File.join(RAILS_ROOT, 'public', 'images', 'icons-mime', 'icon2.png')).returns(false)

    assert_equal 'icons-mime/icon1.png', icon_for_article(art1)
    assert_equal 'icons-mime/unknown.png', icon_for_article(art2)
  end

  should 'list all the folder\'s children to the owner' do
    profile = create_user('Folder Owner').person
    folder = fast_create(Folder, {:name => 'Parent Folder', :profile_id => profile.id})
    sub_folder = fast_create(Folder, {:name => 'Child Folder', :parent_id => folder.id,
                             :profile_id => profile.id})
    sub_blog = fast_create(Blog, {:name => 'Child Blog', :parent_id => folder.id,
                           :profile_id => profile.id})
    sub_article = fast_create(Article, {:name => 'Not Public Child Article', :parent_id =>
                              folder.id, :profile_id => profile.id, :published => false})

    result = folder.list_articles(folder.children, profile)

    assert_match 'Child Folder', result
    assert_match 'Not Public Child Article', result
    assert_match 'Child Blog', result
  end

  should 'list the folder\'s children that are public to the user' do
    profile = create_user('Folder Owner').person
    profile2 = create_user('Folder Viwer').person
    folder = fast_create(Folder, {:name => 'Parent Folder', :profile_id => profile.id})
    public_article = fast_create(Article, {:name => 'Public Article', :parent_id =>
                              folder.id, :profile_id => profile.id, :published => true})
    not_public_article = fast_create(Article, {:name => 'Not Public Article', :parent_id =>
                              folder.id, :profile_id => profile.id, :published => false})

    result = folder.list_articles(folder.children, profile2)

    assert_match 'Public Article', result
    assert_no_match /Not Public Article/, result
  end

  should ' not list the folder\'s children to the user because the owner\'s profile is not public' do
    profile = create_user('folder-owner').person
    profile.public_profile = false
    profile.save!
    profile2 = create_user('Folder Viwer').person
    folder = fast_create(Folder, {:name => 'Parent Folder', :profile_id => profile.id})
    article = fast_create(Article, {:name => 'Article', :parent_id => folder.id, :profile_id => profile.id})

    result = folder.list_articles(folder.children, profile2)

    assert_no_match /Article/, result
  end

  should ' not list the folder\'s children to the user because the owner\'s profile is not visible' do
    profile = create_user('folder-owner').person
    profile.visible = false
    profile.save!
    profile2 = create_user('Folder Viwer').person
    folder = fast_create(Folder, {:name => 'Parent Folder', :profile_id => profile.id})
    article = fast_create(Article, {:name => 'Article', :parent_id => folder.id, :profile_id => profile.id})

    result = folder.list_articles(folder.children, profile2)

    assert_no_match /Article/, result
  end

  should 'list subitems as HTML content' do
    profile = create_user('folder-owner').person
    folder = fast_create(Folder, {:name => 'Parent Folder', :profile_id => profile.id})
    article = fast_create(Article, {:name => 'Article1', :parent_id => folder.id, :profile_id => profile.id})
    article = fast_create(Article, {:name => 'Article2', :parent_id => folder.id, :profile_id => profile.id})

    result = folder.list_articles(folder.children, profile)

    assert_tag_in_string result, :tag => 'td', :descendant => { :tag => 'a', :attributes => { :href => /.*\/folder-owner\/my-article-[0-9]*(\?|$)/ } }, :content => /Article1/
    assert_tag_in_string result, :tag => 'td', :descendant => { :tag => 'a', :attributes => { :href => /.*\/folder-owner\/my-article-[0-9]*(\?|$)/ } }, :content => /Article2/
  end

  should 'explictly advise if empty' do
    profile = create_user('folder-owner').person
    folder = fast_create(Folder, {:name => 'Parent Folder', :profile_id => profile.id})
    result = folder.list_articles(folder.children, profile)

    assert_match '(empty folder)', result
  end

end
