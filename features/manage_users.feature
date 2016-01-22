Feature: manage users
  As an environment administrator
  I want to manage users
  In order to remove, activate, deactivate users, and set admin roles.

Background:
  Given the following users
    | login       | name         |
    | joaosilva   | Joao Silva   |
    | paulosantos | Paulo Santos |
  And I am logged in as admin
  And I go to /admin/users

  @selenium
  Scenario: deactive user
    Given I follow "Deactivate user" within "tr[title='Joao Silva']"
    When I confirm the browser dialog
    Then the field "tr[title='Joao Silva'] td.actions a.icon-activate-user" should be enabled

  @selenium
  Scenario: activate user
    Given I follow "Deactivate user" within "tr[title='Paulo Santos']"
    And I confirm the browser dialog
    And I follow "Activate user" within "tr[title='Paulo Santos']"
    When I confirm the browser dialog
    Then the field "tr[title='Paulo Santos'] td.actions a.icon-deactivate-user" should be enabled

  @selenium
  Scenario: remove user
    Given I follow "Remove" within "tr[title='Joao Silva']"
    And I confirm the browser dialog
    And I go to /admin/users
    Then I should not see "Joao Silva"

  @selenium
  Scenario: admin user
    Given I follow "Set admin role" within "tr[title='Joao Silva']"
    When I confirm the browser dialog
    Then the field "tr[title='Joao Silva'] td.actions a.icon-reset-admin-role" should be enabled

  @selenium
  Scenario: unadmin user
    Given I follow "Set admin role" within "tr[title='Paulo Santos']"
    And I confirm the browser dialog
    And I follow "Reset admin role" within "tr[title='Paulo Santos']"
    When I confirm the browser dialog
    Then the field "tr[title='Paulo Santos'] td.actions a.icon-set-admin-role" should be enabled
