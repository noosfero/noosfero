require File.dirname(__FILE__) + '/../test_helper'
require 'cms_controller'

# Re-raise errors caught by the controller.
class CmsController; def rescue_action(e) raise e end; end

class CmsControllerTest < Test::Unit::TestCase

  fixtures :environments

  def setup
    @controller = CmsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @profile = create_user_with_permission('testinguser', 'post_content')
    login_as :testinguser
  end

  attr_reader :profile

  should 'list top level documents on index' do
    get :index, :profile => profile.identifier

    assert_template 'view'
    assert_equal profile, assigns(:profile)
    assert_nil assigns(:article)
    assert_kind_of Array, assigns(:subitems)
  end

  should 'be able to view a particular document' do

    a = profile.articles.build(:name => 'blablabla')
    a.save!
    
    get :view, :profile => profile.identifier, :id => a.id

    assert_template 'view'
    assert_equal a, assigns(:article)
    assert_equal [], assigns(:subitems)

    assert_kind_of Array, assigns(:subitems)
  end

  should 'be able to edit a document' do
    a = profile.articles.build(:name => 'test')
    a.save!

    get :edit, :profile => profile.identifier, :id => a.id
    assert_template 'edit'
  end

  should 'be able to create a new document' do
    get :new, :profile => profile.identifier
    assert_response :success
    assert_template 'select_article_type'

    # TODO add more types here !!
    [ TinyMceArticle, TextileArticle ].each do |item|
      assert_tag :tag => 'a', :attributes => { :href => "/myprofile/#{profile.identifier}/cms/new?type=#{item.name}" }
    end
  end

  should 'present edit screen after choosing article type' do
    get :new, :profile => profile.identifier, :type => 'TinyMceArticle'
    assert_template 'edit'

    assert_tag :tag => 'form', :attributes => { :action => "/myprofile/#{profile.identifier}/cms/new", :method => /post/i }, :descendant => { :tag => "input", :attributes => { :type => 'hidden', :value => 'TinyMceArticle' }}
  end

  should 'be able to save a document' do
    assert_difference Article, :count do
      post :new, :type => 'TinyMceArticle', :profile => profile.identifier, :article => { :name => 'a test article', :body => 'the text of the article ...' }
    end
  end

  should 'be able to set home page' do
    a = profile.articles.build(:name => 'my new home page')
    a.save!
    
    assert_not_equal a, profile.home_page

    post :set_home_page, :profile => profile.identifier, :id => a.id

    assert_redirected_to :action => 'view', :id => a.id

    profile.reload
    assert_equal a, profile.home_page
  end

  should 'set last_changed_by when creating article' do
    login_as(profile.identifier)

    post :new, :type => 'TinyMceArticle', :profile => profile.identifier, :article => { :name => 'changed by me', :body => 'content ...' }

    a = profile.articles.find_by_path('changed-by-me')
    assert_not_nil a
    assert_equal profile, a.last_changed_by
  end

  should 'set last_changed_by when updating article' do
    other_person = create_user('otherperson').person

    a = profile.articles.build(:name => 'my article')
    a.last_changed_by = other_person
    a.save!
    
    login_as(profile.identifier)
    post :edit, :profile => profile.identifier, :id => a.id, :article => { :body => 'new content for this article' }

    a.reload

    assert_equal profile, a.last_changed_by
  end

  should 'edit by using the correct template to display the editor depending on the mime-type' do
    a = profile.articles.build(:name => 'test document')
    a.save!
    assert_equal 'text/html', a.mime_type

    get :edit, :profile => profile.identifier, :id => a.id
    assert_response :success
    assert_template 'edit'
  end

  should 'convert mime-types to action names' do
    obj = mock
    obj.extend(CmsHelper)

    assert_equal 'text_html', obj.mime_type_to_action_name('text/html')
    assert_equal 'image', obj.mime_type_to_action_name('image')
    assert_equal 'application_xnoosferosomething', obj.mime_type_to_action_name('application/x-noosfero-something')
  end

  should 'be able to remove article' do
    a = profile.articles.build(:name => 'my-article')
    a.save!

    assert_difference Article, :count, -1 do
      post :destroy, :profile => profile.identifier, :id => a.id
      assert_redirected_to :action => 'index'
    end
  end

  should 'be able to create a RSS feed' do
    login_as('ze')
    assert_difference RssFeed, :count do
      post :new, :type => RssFeed.name, :profile => profile.identifier, :article => { :name => 'feed', :limit => 15, :include => 'all', :feed_item_description => 'body' }
      assert_response :redirect
    end
  end

  should 'be able to update a RSS feed' do
    login_as('ze')
    feed = RssFeed.create!(:name => 'myfeed', :limit => 5, :feed_item_description => 'body', :include => 'all', :profile_id => profile.id)
    post :edit, :profile => profile.identifier, :id => feed.id, :article => { :limit => 77, :feed_item_description => 'abstract', :include => 'parent_and_children' }
    assert_response :redirect

    updated = RssFeed.find(feed.id)
    assert_equal 77, updated.limit
    assert_equal 'abstract', updated.feed_item_description
    assert_equal 'parent_and_children', updated.include
  end

  should 'be able to upload a file' do
    assert_difference UploadedFile, :count do
      post :new, :type => UploadedFile.name, :profile => profile.identifier, :article => { :uploaded_data => fixture_file_upload('/files/test.txt', 'text/plain')}
    end
  end

  should 'be able to update an uploaded file' do
    flunk 'pending'
  end

  should 'not offer to create children if article does not accept them' do
    flunk 'pending'
  end

end
