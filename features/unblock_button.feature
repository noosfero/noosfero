Feature: unblock button
  As an environment administrator
  I want to unblock an enterprise
  In order to try to activate it again

  Background:
    Given the following enterprise
      | identifier        | name              |
      | sample-enterprise | Sample Enterprise |
    And the following blocks
      | owner             | type                           |
      | sample-enterprise | DisabledEnterpriseMessageBlock |
    And Sample Enterprise is disabled

  Scenario: the environment administrator unblocks a blocked enterprise
    Given I am logged in as admin
    And Sample Enterprise is blocked
    And I am on Sample Enterprise's homepage
    When I follow "Unblock"
    Then I should not see "Unblock"

  Scenario: a not administrator user can't see "Unblock" button
    Given the following user
      | login     | name       |
      | joaosilva | Joao Silva |
    And I am logged in as "joaosilva"
    And Sample Enterprise is blocked
    When I am on Sample Enterprise's homepage
    Then I should not see "Unblock"

  Scenario: a not blocked enterprise should not show "Unblock" button
    Given I am logged in as admin
    When I am on Sample Enterprise's homepage
    Then I should not see "Unblock"
