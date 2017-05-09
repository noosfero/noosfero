require 'test_helper'

class PublicAccessRestrictionPluginPublicPageControllerTest < ActionController::TestCase

  def setup
    @profile = fast_create(Organization)
    @user = create_user
  end

  should 'display public page if the profile says so and the user is not logged in' do
    data = { show_public_page: true }
    Noosfero::Plugin::Settings.new(@profile, PublicAccessRestrictionPlugin, data).save!

    get :index, profile: @profile.identifier
    assert_template :index
  end

  should 'not display public page if the user is logged in' do
    data = { show_public_page: false }
    Noosfero::Plugin::Settings.new(@profile, PublicAccessRestrictionPlugin, data).save!
    login_as(@user.login)

    get :index, profile: @profile.identifier
    assert_redirected_to controller: 'profile', action: 'index'
  end

  should 'display public page if the profile does not say so' do
    data = { show_public_page: false }
    Noosfero::Plugin::Settings.new(@profile, PublicAccessRestrictionPlugin, data).save!

    get :index, profile: @profile.identifier
    assert_redirected_to controller: 'profile', action: 'index'
  end

end
