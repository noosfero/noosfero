Feature: push notification user config
  As an user
  I want to configure the notification I want to receive

  Background:
    Given plugin PushNotification is enabled on environment
    Given the following users
      |login | name |
      |joaosilva| Joao Silva |

  Scenario: the user should see his devices
    Given that the user joaosilva has the following devices
      | token | name |
      | "token_1" | "Banana Phone" |
      | "token_2" | "Zamzung Phone" |
    Given I am logged in as "joaosilva"
    Given I go to joaosilva's control panel
    When I follow "Notifications"
    Then I should see "Banana Phone"
    And I should see "Zamzung Phone"

  Scenario: the user should delete his devices
    Given that the user joaosilva has the following devices
      | token | name |
      | "token_1" | "Zamzung Phone" |
    Given I am logged in as "joaosilva"
    Given I go to joaosilva's control panel
    When I follow "Notifications"
    When I follow "delete_device_1"
    Then I should be on /myprofile/joaosilva/plugin/push_notification
    And I should not see "Zamzung Phone"

  Scenario: the user should only see the notifications enabled in the environment
    Given the following notifications
      |name |
      |add_friend |
      |new_article |
    Given I am logged in as "joaosilva"
    Given I go to joaosilva's control panel
    When I follow "Notifications"
      Then I should see "Add Friend"
      And I should see "New Article"
      And I should not see "New Member"
      And I should not see "Approve Article"

  Scenario: the user should be able to enable notifications
    Given the following notifications
      |name |
      |add_friend |
      |new_article |
    Given I am logged in as "joaosilva"
    Given I go to joaosilva's control panel
    When I follow "Notifications"
    And I check "settings_add_friend"
    And I check "settings_new_article"
    When I press "Save"
    Then the "settings_add_friend" checkbox should be checked
    Then the "settings_new_article" checkbox should be checked

    Scenario: the user should be able to disable notifications
      Given the following notifications
        | name |
        | add_friend |
        | new_article |
      Given that the user joaosilva has the following notifications
        | name |
        | add_friend |
      Given I am logged in as "joaosilva"
      Given I go to joaosilva's control panel
      When I follow "Notifications"
      And I uncheck "settings_add_friend"
      When I press "Save"
      Then the "settings_add_friend" checkbox should not be checked
