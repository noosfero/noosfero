require "#{File.dirname(__FILE__)}/../test_helper"

class EditEnterpriseTest < ActionController::IntegrationTest
  all_fixtures
  def test_edit_an_enterprise
    get '/myprofile/ze/enterprise'
    assert_response :redirect

    login('ze', 'test')

    get '/myprofile/ze/enterprise'
    assert_response :redirect

    follow_redirect!
    assert_response :success
    assert_tag :tag => 'a', :attributes => {:href => '/myprofile/ze/enterprise/edit/5'}

    get '/myprofile/ze/enterprise/edit/5'
    assert_response :success
    assert_tag :tag => 'input', :attributes => {:name => 'enterprise[name]'}

    post '/myprofile/ze/enterprise/update/5', :enterprise => {'name' => 'new_name' }
    assert_response :redirect

    follow_redirect!
    assert_response :redirect

    follow_redirect!
    assert_equal '/myprofile/ze/enterprise/show/5', path

  end
end
