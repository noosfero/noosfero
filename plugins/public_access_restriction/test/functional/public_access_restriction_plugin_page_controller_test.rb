require 'test_helper'

class PublicAccessRestrictionPluginPageControllerTest < ActionController::TestCase

  def setup
    user = create_user
    login_as(user.login)
  end

  Organization.descendants.each do |klass|
    should "update public_page data for #{klass.name} objects" do
      profile = fast_create(klass)
      data = { show_public_page: '1', public_page_content: 'public' }

      post :update, profile: profile.identifier, profile_data: data
      profile.reload
      settings = Noosfero::Plugin::Settings.new(profile, PublicAccessRestrictionPlugin)
      assert settings.show_public_page
      assert_equal 'public', settings.public_page_content
    end
  end

end
