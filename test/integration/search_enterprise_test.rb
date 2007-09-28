require "#{File.dirname(__FILE__)}/../test_helper"

class SearchEnterpriseTest < ActionController::IntegrationTest
  all_fixtures

  def test_search_by_name_or_tag
    login('ze', 'test')
    get '/myprofile/ze/membership_editor'
    assert_response :success
    assert_tag :tag => 'input', :attributes => {'name', 'query'}

    get '/myprofile/ze/membership_editor/search', :query => 'bla'
    assert_response :success
  end
end
