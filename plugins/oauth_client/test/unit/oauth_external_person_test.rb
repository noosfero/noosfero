
require 'test_helper'

class OauthExternalPersonTest < ActiveSupport::TestCase

  def setup
    provider = fast_create(OauthClientPlugin::Provider, name: "GitHub")
    @external_person = fast_create(ExternalPerson, name: "testuser", email: "test@email.com",
                                   identifier: "testuser")
    OauthClientPlugin::GithubAuth.create!(profile: @external_person, provider: provider)

    @oauth_external_person = fast_create(OauthClientPlugin::OauthExternalPerson,
                                         name: "testuser", email: "test@email.com",
                                         identifier: "testuser")
    OauthClientPlugin::GithubAuth.create!(profile: @oauth_external_person,
                                          provider: provider)
  end

  should "not orverride info from a regular external person" do
    assert_not_equal @external_person.avatar, @oauth_external_person.avatar
    assert_not_equal @external_person.url, @oauth_external_person.url
    assert_not_equal @external_person.admin_url, @oauth_external_person.admin_url
    assert_not_equal @external_person.public_profile_url,
                     @oauth_external_person.public_profile_url
  end

  should "not override the Image class from a regular external person" do
    assert @external_person.image.is_a? ExternalPerson::Image
    assert @oauth_external_person.image.is_a? OauthClientPlugin::OauthExternalPerson::Image
  end
end
