Feature: require authentication to comment

  Background:
    Given plugin RequireAuthToComment is enabled on environment
    And the following users
      | login   |
      | bozo    |

  Scenario: enabling unauthenticated comment per profile
    Given I am logged in as "bozo"
    When I edit my profile
    And I check "Accept comments from unauthenticated users"
    And I press "Save"
    Then I edit my profile
    And the "Accept comments from unauthenticated users" checkbox should be checked
