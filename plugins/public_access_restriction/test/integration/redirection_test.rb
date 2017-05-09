require "test_helper"

class RedirectionTest < ActionDispatch::IntegrationTest

  def setup
    @profile = fast_create(Organization)
    @user = create_user('testuser')
    @user.activate
    Environment.default.enable_plugin(PublicAccessRestrictionPlugin.name)
  end

  should 'redirect to login page if user is not logged and public page is not enabled' do
    get "/profile/#{@profile.identifier}"
    assert_redirected_to controller: 'account', action: 'login'
  end

  should 'redirect to public page if user is not logged and public page is enabled' do
    data = { show_public_page: true, public_page_content: 'This is public' }
    Noosfero::Plugin::Settings.new(@profile, PublicAccessRestrictionPlugin, data).save!

    get_via_redirect "/profile/#{@profile.identifier}"
    assert_match /This is public/, @response.body
  end

  should 'redirect to profile page when opening the public page and the user is logged' do
    data = { show_public_page: true, public_page_content: 'This is public' }
    Noosfero::Plugin::Settings.new(@profile, PublicAccessRestrictionPlugin, data).save!

    login 'testuser', 'testuser'
    get "/profile/#{@profile.identifier}/plugin/public_access_restriction/public_page"
    assert_redirected_to controller: 'profile', action: 'index'
  end

end
