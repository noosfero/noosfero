Feature: federated networks
  As an administrator
  I want to associate my environment with federated networks

  Background:
    Given I am logged in as admin
    Given the following federated networks
      | id | name | url      |
      | 1  | Test | test.org |

  Scenario: admin user could access the federated networks
    Given I follow "Administration"
    When I follow "Federated Networks"
    Then I should be on /admin/federated_networks

  Scenario: admin user could associated a federated network to the environment
    Given I go to /admin/federated_networks
    And I check "environment_federated_network_ids_1"
    When I press "Save changes"
    Then I should be on /admin/federated_networks
