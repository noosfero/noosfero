require "#{File.dirname(__FILE__)}/../test_helper"

class EditEnterpriseTest < ActionController::IntegrationTest
  all_fixtures
  def test_edit_an_enterprise
    get '/myprofile/colivre/enterprise_editor'
    assert_response :success

    login('ze', 'test')

    get '/myprofile/colivre/profile_editor'
    assert_response :success
    assert_tag :tag => 'a', :attributes => { :href => '/myprofile/colivre/enterprise_editor'}

    get '/myprofile/colivre/enterprise_editor'
    assert_response :success
    assert_tag :tag => 'a', :attributes => {:href => '/myprofile/colivre/enterprise_editor/edit/5'}

    get '/myprofile/colivre/enterprise_editor/edit/5'
    assert_response :success
    assert_tag :tag => 'input', :attributes => {:name => 'enterprise[name]'}

    post '/myprofile/colivre/enterprise_editor/update/5', :enterprise => {'name' => 'new_name'}
    assert_response :redirect

    follow_redirect!
    assert_response :success
    assert_equal '/myprofile/colivre/enterprise_editor', path

  end
end
