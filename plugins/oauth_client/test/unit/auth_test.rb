require 'test_helper'

class AuthTest < ActiveSupport::TestCase

  def setup
    @person = fast_create(Person)
    @provider = fast_create(OauthClientPlugin::Provider, name: "GitHub")
    @external_person = fast_create(ExternalPerson, name: "testuser", email: "test@email.com",
                                                   identifier: "testuser")

    OauthClientPlugin::Auth.any_instance.stubs(:external_person_image_url).returns("http://some.host/image")
    OauthClientPlugin::Auth.any_instance.stubs(:external_person_uid).returns("j4b25cj234hb5n235")
    OauthClientPlugin::Provider.any_instance.stubs(:client_options).returns({site: "http://host.com"})
  end

  should "not create an auth without a related profile or external person" do
    auth = OauthClientPlugin::Auth.new(provider: @provider)
    assert_not auth.valid?
  end

  should "create an auth with an external person" do
    auth = OauthClientPlugin::Auth.create!(profile: @external_person,
                                           provider: @provider)
    assert auth.id.present?
  end

  should "create an auth with a profile" do
    auth = OauthClientPlugin::Auth.create!(profile: @person, provider: @provider)
    assert auth.id.present?
  end

  should "create an auth for a custom provider" do
    auth = OauthClientPlugin::Auth.create_for_strategy("github", provider: @provider,
                                                                 profile: @person)
    assert auth.id.present?
    assert auth.is_a? OauthClientPlugin::GithubAuth
  end

  STRATEGIES = %w[facebook github google_oauth2 noosfero_oauth2 twitter]
  STRATEGIES.each do |strategy|
    should "override the external person's image url for #{strategy} strategy" do
      auth = OauthClientPlugin::Auth.create_for_strategy(strategy, provider: @provider,
                                                                   profile: @external_person)
      assert_not auth.image_url.nil?
    end

    should "override the external person's profile url for #{strategy} strategy" do
      auth = OauthClientPlugin::Auth.create_for_strategy(strategy, provider: @provider,
                                                                   profile: @external_person)
      assert_not auth.profile_url.nil?
    end

    should "override the external person's profile settings url for #{strategy} strategy" do
      auth = OauthClientPlugin::Auth.create_for_strategy(strategy, provider: @provider,
                                                                   profile: @external_person)
      assert_not auth.settings_url.nil?
    end
  end

end
