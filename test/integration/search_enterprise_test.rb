require "#{File.dirname(__FILE__)}/../test_helper"

class SearchEnterpriseTest < ActionController::IntegrationTest
  all_fixtures

  def test_search_by_name_or_tag
    login('ze', 'test')
    get '/myprofile/ze/enterprise'
    assert_response :redirect

    follow_redirect!
    assert_response :success
    assert_tag :tag => 'input', :attributes => {'name', 'query'}

    get '/myprofile/ze/enterprise/search', :query => 'bla'
    assert_response :success
  end
end
