Feature: export users
  As an administrator
  I want to export user from my environment

  Background:
    Given the following user
      | login |
      | ultraje |

  Scenario: Export users as XML
    Given I am logged in as admin
    When I follow "Administration"
    And I follow "Manage users"
    And I follow "[XML]"
    Then I should see "ultraje"

  Scenario: Export users as CSV
    Given I am logged in as admin
    When I follow "Administration"
    And I follow "Manage users"
    And I follow "[CSV]"
    Then I should see "name;email"
    And I should see "ultraje"

  Scenario: Cant access as normal user
    Given I am logged in as "ultraje"
    When I go to /admin/users
    Then I should see "Access denied"
