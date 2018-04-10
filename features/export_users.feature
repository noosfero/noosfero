Feature: export users
  As an administrator
  I want to export user from my environment

  Background:
    Given the following user
      | login |
      | ultraje |

  @selenium
  Scenario: Export users as XML
    Given I am logged in as admin
    When I go to /admin/users
    And I follow "User list as [XML]"
    Then I should see "ultraje"

  @selenium
  Scenario: Export users as CSV
    Given I am logged in as admin
    When I go to /admin/users
    And I follow "User list as [CSV]"
    # Then I should see "name;email"
    # the step above can be seen in the downloaded document, so it cannot be seen
    # by the selenium/cucumber test suite
    And I should see "ultraje"

  Scenario: Cant access as normal user
    Given I am logged in as "ultraje"
    When I go to /admin/users
    Then I should see "Access denied"
