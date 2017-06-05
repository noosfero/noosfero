require_relative "../test_helper"

class AngularThemeTest < ActionDispatch::IntegrationTest

  should 'render index page for angular theme when access an inexistent route' do
    Theme.stubs(:angular_theme?).returns(true)
    profile = fast_create(Community)
    get "/myprofile/#{profile.identifier}/members"
    assert_response 200
  end

  should 'render not found when access an inexistent route' do
    Theme.stubs(:angular_theme?).returns(false)
    profile = fast_create(Community)
    get "/myprofile/#{profile.identifier}/members"
    assert_response 404
  end

  should 'render not found when theme is angular and path starts with api' do
    Theme.stubs(:angular_theme?).returns(false)
    profile = fast_create(Community)
    get "/api/v1/some_endpoint"
    assert_response 404
  end

  should 'render index page for angular theme when access myprofile route of an angular profile' do
    Theme.stubs(:angular_theme?).with('noosfero').returns(false)
    Theme.stubs(:angular_theme?).with('angular').returns(true)
    profile = fast_create(Community)
    profile.update_attribute(:theme, 'angular')
    get "/myprofile/#{profile.identifier}/members"
    assert_response 200
  end
end
