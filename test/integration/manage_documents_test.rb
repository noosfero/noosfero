require "#{File.dirname(__FILE__)}/../test_helper"

class ManageDocumentsTest < ActionController::IntegrationTest

  fixtures :users, :profiles, :comatose_pages, :domains, :virtual_communities

  def test_creation_of_a_new_article
    count = Article.count

    login('ze', 'test')

    get '/cms/ze'
    assert_response :success

    get '/cms/ze/new'
    assert_response :success
    assert_tag :tag => 'form', :attributes => { :action => '/cms/ze/new' }

    post '/cms/ze/new', :page => { :title => 'my new article', :body => 'this is the text of my new article' , :parent_id => Article.find_by_path('ze').id }
    assert_response :redirect

    follow_redirect!
    assert_response :success

    assert_equal count + 1, Article.count

  end

  def test_update_of_an_existing_article
    login('ze', 'test')

    get '/cms/ze'
    assert_response :success

    id = Comatose::Page.find_by_path('ze').id
    get "cms/ze/edit/#{id}"
    assert_response :success
    assert_tag :tag => 'form', :attributes => { :action => "/cms/ze/edit/#{id}" }

    post "cms/ze/edit/#{id}", :page => { :body => 'changed_body' }
    assert_response :redirect
    
  end

  def test_removing_an_article
    article = Article.create!(:title => 'to be removed', :body => 'go to hell', :parent_id => Article.find_by_path('ze').id)
    count = Article.count

    get '/cms/ze'
    assert_response :success

    post "/cms/ze/delete/#{article.id}"
    assert_response :redirect

    assert_raise ActiveRecord::RecordNotFound do
      Article.find(article.id)
    end
  end

  # FIXME: add tests for page reordering 

end
