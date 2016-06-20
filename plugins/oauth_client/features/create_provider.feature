Feature: Create Twitter provider
  As a environment admin
  I want to be able to create a new twitter provider
  So that users can login wth different strategies

Background:
    Given "OauthProvider" plugin is enabled
    And I am logged in as admin
    And I go to /admin/plugins
    And I check "Oauth Client Plugin"
    And I press "Save changes"

Scenario: Create a twitter provider
    Given I go to /admin/plugin/oauth_client/new
    And I fill in "oauth_client_plugin_provider_name" with "myid"
    And I fill in "oauth_client_plugin_provider[name]" with "google"
    And I fill in "oauth_client_plugin_provider_client_secret" with "mysecret"
    And I check "oauth_client_plugin_provider[enabled]"
    And I select "twitter" from "oauth_client_plugin_provider_strategy"
    Then I should see "To use this provider you need to request the user email in your app"
