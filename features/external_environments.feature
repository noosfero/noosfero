Feature: external environments
  As an administrator
  I want to associate my environment with external environments

  Background:
    Given I am logged in as admin
    Given the following external environments
      | id | name | url      |
      | 1  | Test | test.org |

  Scenario: admin user could access the external environments
    Given I follow "Administration"
    When I follow "External environments"
    Then I should be on /admin/external_environments

  Scenario: admin user could associated a external environment to the environment
    Given I go to /admin/external_environments
    And I check "environment_external_environment_ids_1"
    When I press "Save changes"
    Then I should be on /admin/external_environments
