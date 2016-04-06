Feature: push notification administration
  As an administrator
  I want to configure the push notification plugin

  Background:
    Given plugin PushNotification is enabled on environment
    Given I am logged in as admin

  Scenario: configure the api key
    Given I go to /admin/plugin/push_notification
    And I fill in "Server API key" with "ABCDEFGH1234567890"
    When I press "Save"
    Then I should be on /admin/plugin/push_notification
    Then the "Server API key" field should contain "ABCDEFGH1234567890"

  Scenario: change the api key
    Given that "old_key" is the server api key
    Given I go to /admin/plugin/push_notification
    Then the "Server API key" field should contain "old_key"
    When I fill in "Server API key" with "new_key"
    And I press "Save"
    Then I should be on /admin/plugin/push_notification
    Then the "Server API key" field should contain "new_key"

  Scenario: enable notifications
    Given I go to /admin/plugin/push_notification
    And I check "settings_add_member"
    And I check "settings_new_article"
    When I press "Save"
    Then the "settings_add_member" checkbox should be checked
    Then the "settings_new_article" checkbox should be checked

  Scenario: disable notifications
    Given the following notifications
      |name|
      |add_friend|
      |add_member|
    And I go to /admin/plugin/push_notification
    Then the "settings_add_friend" checkbox should be checked
    Then the "settings_add_member" checkbox should be checked
    And I uncheck "settings_add_friend"
    And I uncheck "settings_add_member"
    When I press "Save"
    Then I should be on /admin/plugin/push_notification
    Then the "settings_add_friend" checkbox should not be checked
    Then the "settings_add_member" checkbox should not be checked
