Feature: remove administrator role
  As an organization administrator
  I want to remove my administrator role
  In order to stop administrating the organization

  Background:
    Given the following users
      | login      | name        |
      | joaosilva  | Joao Silva  |
      | mariasouza | Maria Souza |
    And the following community
      | name        | identifier  |
      | Nice people | nice-people |
    And "Joao Silva" is a member of "Nice people"
    And I am logged in as "joaosilva"

  Scenario: the last administrator removes his administrator role and must choose the new administrator
    Given "Maria Souza" is a member of "Nice people"
    And I am on Nice people's members management
    And I follow "Edit"
    And I uncheck "Profile Administrator"
    When I press "Save changes"
    Then I should see "Since you are the last administrator, you must choose"

  Scenario: the last administrator and member removes his administrator role and the next member to join becomes the new administrator
    Given I am on Nice people's members management
    And I follow "Edit"
    And I uncheck "Profile Administrator"
    And I uncheck "Profile Member"
    When I press "Save changes"
    Then I should see "Since you are the last administrator and there is no other member in this community"
    And I press "Ok, I want to leave"
    And I am logged in as "mariasouza"
    When I go to Nice people's join page
    Then "Maria Souza" should be admin of "Nice people"

  Scenario: the last administrator and member removes his administrator role and the next member to join becomes the new administrator even if the organization is closed.
    Given the community "Nice people" is closed
    And I am on Nice people's members management
    And I follow "Edit"
    And I uncheck "Profile Administrator"
    And I uncheck "Profile Member"
    When I press "Save changes"
    Then I should see "Since you are the last administrator and there is no other member in this community"
    And I press "Ok, I want to leave"
    And I am logged in as "mariasouza"
    When I go to Nice people's join page
    Then "Maria Souza" should be admin of "Nice people"
