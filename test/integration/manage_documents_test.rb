require "#{File.dirname(__FILE__)}/../test_helper"

class ManageDocumentsTest < ActionController::IntegrationTest

  all_fixtures

  def test_creation_of_a_new_article
    count = Article.count

    login('ze', 'test')

    assert_tag :tag => 'a', :attributes => { :href => '/myprofile/ze/cms' }

    get '/myprofile/ze/cms'
    assert_response :success

    assert_tag :tag => 'a', :attributes => { :href => '/myprofile/ze/cms/new' }
    get '/myprofile/ze/cms/new'
    assert_response :success
    assert_tag :tag => 'form', :attributes => { :action => '/myprofile/ze/cms/new' }

    post '/myprofile/ze/cms/new', :page => { :title => 'my new article', :body => 'this is the text of my new article' , :parent_id => Article.find_by_path('ze').id }
    assert_response :redirect

    follow_redirect!
    assert_response :success
    assert_equal '/myprofile/ze/cms', path

    assert_equal count + 1, Article.count

  end

  def test_update_of_an_existing_article
    login('ze', 'test')

    get '/myprofile/ze/cms'
    assert_response :success

    id = Comatose::Page.find_by_path('ze').id
    get "myprofile/ze/cms/edit/#{id}"
    assert_response :success
    assert_tag :tag => 'form', :attributes => { :action => "/myprofile/ze/cms/edit/#{id}" }

    post "myprofile/ze/cms/edit/#{id}", :page => { :body => 'changed_body' }
    assert_response :redirect
    follow_redirect!
    assert_equal '/myprofile/ze/cms', path
    
  end

  def test_removing_an_article

    article = Article.create!(:title => 'to be removed', :body => 'go to hell', :parent_id => Article.find_by_path('ze').id)
    count = Article.count

    get '/myprofile/ze/cms'
    assert_response :success
    assert_tag :tag => 'a', :attributes => { :href => "/myprofile/ze/cms/delete/#{article.id}" }

    post "/myprofile/ze/cms/delete/#{article.id}"
    assert_response :redirect
    follow_redirect!
    assert_equal '/myprofile/ze/cms', path

    assert_raise ActiveRecord::RecordNotFound do
      Article.find(article.id)
    end
  end

  # FIXME: add tests for page reordering 

end
