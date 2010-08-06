Feature: export users
  As an administrator
  I want to export user from my environment

  Background:
    Given the following user
      | login |
      | ultraje |

  Scenario: Manage users not implemented yet
    Given I am logged in as admin
    When I go to /admin/users
    Then I should see "Not implemented yet!"

  Scenario: Export users as XML
    Given I am logged in as admin
    When I go to /admin/users.xml
    Then I should see "ultraje"

  Scenario: Export users as CSV
    Given I am logged in as admin
    When I go to /admin/users.csv
    Then I should see "name;email"
    And I should see "ultraje"

  Scenario: Cant access as normal user
    Given I am logged in as "ultraje"
    When I go to /admin/users
    Then I should see "Access denied"
