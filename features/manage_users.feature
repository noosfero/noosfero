Feature: manage users
  As an environment administrator
  I want to manage users
  In order to remove, activate, deactivate users, and set admin roles.

Background:
  Given the following users
    | login       | name         |
    | joaosilva   | Joao Silva   |
    | paulosantos | Paulo Santos |
  Given I am logged in as admin
  Given I go to /admin/users

  @selenium
  Scenario: deactive user
    When I follow "Deactivate user" within "tr[title='Joao Silva']"
    And I confirm the "Do you want to deactivate this user?" dialog
    Then I should see "Activate user" within "tr[title='Joao Silva']"

  @selenium
  Scenario: activate user
    Given I follow "Deactivate user" within "tr[title='Paulo Santos']"
    Given I confirm the "Do you want to deactivate this user?" dialog
    When I follow "Activate user" within "tr[title='Paulo Santos']"
    And I confirm the "Do you want to activate this user?" dialog
    Then I should see "Deactivate user" within "tr[title='Paulo Santos']"

  @selenium
  Scenario: remove user
    When I follow "Remove" within "tr[title='Joao Silva']"
    And I confirm the "Do you want to remove this user?" dialog
    And I go to /admin/users
    Then I should not see "Joao Silva"

  @selenium
  Scenario: admin user
    When I follow "Set admin role" within "tr[title='Joao Silva']"
    And I confirm the "Do you want to set this user as administrator?" dialog
    Then I should see "Reset admin role" within "tr[title='Joao Silva']"

  @selenium
  Scenario: unadmin user
    Given I follow "Set admin role" within "tr[title='Paulo Santos']"
    And I confirm the "Do you want to set this user as administrator?" dialog
    When I follow "Reset admin role" within "tr[title='Paulo Santos']"
    And I confirm the "Do you want to reset this user as administrator?" dialog
    Then I should see "Set admin role" within "tr[title='Paulo Santos']"
