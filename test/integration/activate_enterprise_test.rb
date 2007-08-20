require "#{File.dirname(__FILE__)}/../test_helper"

class ActivateEnterpriseTest < ActionController::IntegrationTest
  all_fixtures

  def test_activate_approved_enterprise
    login('ze', 'test')

    get '/admin/enterprise'
    assert_response :redirect

    follow_redirect!
    assert_response :success
    assert_tag :tag => 'a', :attributes => {:href => '/admin/enterprise/activate/5'}

    post '/admin/enterprise/activate/5'
    assert_response :redirect

    follow_redirect!
    assert_response :redirect

    follow_redirect!
    assert_response :success
  end
end
