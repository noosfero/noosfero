require File.dirname(__FILE__) + '/../test_helper'

class FolderHelperTest < Test::Unit::TestCase

  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::UrlHelper
  include ActionController::UrlWriter
  include ActionView::Helpers::AssetTagHelper
  include DatesHelper

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
    folder = fast_create(Folder, :profile_id => profile.id)
    sub_folder = fast_create(Folder, {:parent_id => folder.id, :profile_id => profile.id})
    sub_blog = fast_create(Blog, {:parent_id => folder.id, :profile_id => profile.id})
    sub_article = fast_create(Article, {:parent_id => folder.id, :profile_id => profile.id, :published => false})

    result = available_articles(folder.children, profile)

    assert_includes result, sub_folder
    assert_includes result, sub_article
    assert_includes result, sub_blog
  end

  should 'list the folder\'s children that are public to the user' do
    profile = create_user('Folder Owner').person
    profile2 = create_user('Folder Viwer').person
    folder = fast_create(Folder, :profile_id => profile.id)
    public_article = fast_create(Article, {:parent_id => folder.id, :profile_id => profile.id, :published => true})
    not_public_article = fast_create(Article, {:parent_id => folder.id, :profile_id => profile.id, :published => false})

    result = available_articles(folder.children, profile2)

    assert_includes result, public_article
    assert_not_includes result, not_public_article
  end

  should ' not list the folder\'s children to the user because the owner\'s profile is not public' do
    profile = create_user('folder-owner').person
    profile.public_profile = false
    profile.save!
    profile2 = create_user('Folder Viwer').person
    folder = fast_create(Folder, :profile_id => profile.id)
    article = fast_create(Article, {:parent_id => folder.id, :profile_id => profile.id})

    result = available_articles(folder.children, profile2)

    assert_not_includes result, article
  end

  should ' not list the folder\'s children to the user because the owner\'s profile is not visible' do
    profile = create_user('folder-owner').person
    profile.visible = false
    profile.save!
    profile2 = create_user('Folder Viwer').person
    folder = fast_create(Folder, :profile_id => profile.id)
    article = fast_create(Article, {:parent_id => folder.id, :profile_id => profile.id})

    result = available_articles(folder.children, profile2)

    assert_not_includes result, article
  end

  should 'list subitems as HTML content' do
    profile = create_user('folder-owner').person
    folder = fast_create(Folder, {:name => 'Parent Folder', :profile_id => profile.id})
    article1 = fast_create(Article, {:name => 'Article1', :parent_id => folder.id, :profile_id => profile.id, :updated_at => DateTime.now })
    article2 = fast_create(Article, {:name => 'Article2', :parent_id => folder.id, :profile_id => profile.id, :updated_at => DateTime.now })
    self.stubs(:params).returns({:npage => nil})

    articles = folder.children.find(:all, :order => 'updated_at DESC').paginate(:per_page => 10, :page => params[:npage])
    expects(:user).returns(profile).at_least_once
    expects(:recursive).returns(false).at_least_once
    expects(:pagination_links).with(anything, anything).returns('')
    list = render 'shared/articles_list', binding
    expects(:render).with(:file => 'shared/articles_list', :locals => { :articles => articles, :recursive => false}).returns(list)

    result = list_articles(folder.children)

    assert_tag_in_string result, :tag => 'td', :descendant => { :tag => 'a', :attributes => { :href => /.*\/folder-owner\/my-article-[0-9]*(\?|$)/ } }, :content => /Article1/
    assert_tag_in_string result, :tag => 'td', :descendant => { :tag => 'a', :attributes => { :href => /.*\/folder-owner\/my-article-[0-9]*(\?|$)/ } }, :content => /Article2/
  end

  should 'explictly advise if empty' do
    profile = create_user('folder-owner').person
    folder = fast_create(Folder, {:name => 'Parent Folder', :profile_id => profile.id})
    result = render 'content_viewer/folder', binding

    assert_match '(empty folder)', result
  end

  should 'show body (folder description)' do
    profile = create_user('folder-owner').person
    folder = fast_create(Folder, {:name => 'Parent Folder', :profile_id => profile.id, :body => "This is the folder description"})
    result = render 'content_viewer/folder', binding
    assert_match 'This is the folder description', result
  end


  private
  def render(template, the_binding)
    ERB.new(File.read(RAILS_ROOT + '/app/views/' + template + '.rhtml')).result(the_binding)
  end

end
