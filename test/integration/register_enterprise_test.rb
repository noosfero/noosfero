require "#{File.dirname(__FILE__)}/../test_helper"

class RegisterEnterpriseTest < ActionController::IntegrationTest
  all_fixtures

  def test_register_new_enterprise
    get '/admin/enterprise'
    assert_response :redirect

    login('ze','test')

    get '/admin/enterprise'
    assert_response :redirect

    follow_redirect!
    assert_response :success
    assert_tag :tag => 'a', :attributes => {:href => '/admin/enterprise/register_form'}

    get '/admin/enterprise/register_form'
    assert_response :success
    assert_tag :tag => 'input', :attributes => {:name => 'enterprise[name]'}
    assert_tag :tag => 'input', :attributes => {:name => 'enterprise[identifier]'}
    
    post '/admin/enterprise/register', :enterprise => {'name' => 'new_enterprise', 'identifier' => 'enterprise_new'}
    assert_response :redirect

    follow_redirect!
    assert_response :redirect
    
    follow_redirect!
    assert_response :success
  end
end
