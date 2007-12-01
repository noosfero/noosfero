require "#{File.dirname(__FILE__)}/../test_helper"

class ManageDocumentsTest < ActionController::IntegrationTest

  all_fixtures

  def test_creation_of_a_new_article
    create_user('myuser')

    login('myuser', 'myuser')

    assert_tag :tag => 'a', :attributes => { :href => '/myprofile/myuser'  }
    get '/myprofile/myuser'
    
    assert_tag :tag => 'a', :attributes => { :href => '/myprofile/myuser/cms' }
    get '/myprofile/myuser/cms/new'

    assert_tag :tag => 'form', :attributes => { :action => '/myprofile/myuser/cms/new', :method => /post/i }

    assert_difference Article, :count do
      post '/myprofile/myuser/cms/new', :article => { :name => 'my article', :body => 'this is the body of ther article'}
    end

    assert_response :redirect
    follow_redirect!
    a = Article.find_by_path('my-article')
    assert_equal "/myprofile/myuser/cms/view/#{a.id}", path
  end

  def test_update_of_an_existing_article
    # FIXME
    fail 'need to be rewritten'
  end

  def test_removing_an_article
    # FIXME
    fail 'need to be rewritten'
  end

end
