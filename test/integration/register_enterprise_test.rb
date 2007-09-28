require "#{File.dirname(__FILE__)}/../test_helper"

class RegisterEnterpriseTest < ActionController::IntegrationTest
  all_fixtures

  def test_register_new_enterprise
    get '/myprofile/ze/membership_editor'
    assert_response :redirect

    login('ze','test')

    get '/myprofile/ze/membership_editor'
    assert_response :success
    assert_tag :tag => 'a', :attributes => {:href => '/myprofile/ze/membership_editor/new_enterprise'}

    get '/myprofile/ze/membership_editor/new_enterprise'
    assert_response :success
    assert_tag :tag => 'input', :attributes => {:name => 'enterprise[name]'}
    assert_tag :tag => 'input', :attributes => {:name => 'enterprise[identifier]'}
    
    post '/myprofile/ze/membership_editor/create_enterprise', :enterprise => {'name' => 'new_enterprise', 'identifier' => 'enterprise_new'}
    assert_response :redirect

    follow_redirect!
    assert_response :success
  end
end
