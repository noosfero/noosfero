Feature: accept member
  As an admin user
  I want to accept a member request
  In order to join a community

  Background:
    Given the following users
      | login | name        |
      | mario | Mario Souto |
      | marie | Marie Curie |
    And the following community
      | identifier  | name         |
      | mycommunity | My Community |
    And the community "My Community" is closed
    And "Mario Souto" is admin of "My Community"

  Scenario: a user should see its merbership is pending
    Given I am logged in as "mario"
    And the following communities
      | owner | identifier        | name              | closed |
      | marie | private-community | Private Community | true   |
    And I go to private-community's homepage
    When I follow "Join this community"
    And I go to private-community's homepage
    Then I should see "Your membership is waiting for approval"

  @selenium
  Scenario: approve member and make him become admin in a closed community
    Given "Marie Curie" asked to join "My Community"
    And I am logged in as "mario"
    And I follow "menu-toggle"
    And I should see "Marie Curie wants to be a member of 'My Community'."
    When I follow "Accept"
    Given I am on /myprofile/mycommunity
    And I follow "Manage Members"
    And I fill in "Name or Email" with "Marie Curie"
    And I follow "Search"
    And I should see "Marie Curie"
    And I follow "Edit"
    And I check "Profile Administrator"
    And I follow "Save changes"
    Then "Marie Curie" should be admin of "My Community"

  @selenium
  Scenario: approve a task to accept a member as member in a closed community through tasks
    Given "Marie Curie" asked to join "My Community"
    And I am logged in as "mario"
    And I go to mycommunity's control panel
    And I follow "Tasks"
    And I should see "Marie Curie wants to be a member"
    When I follow "Accept"
    And I follow "Apply!"
    And I wait for 1 seconds
    Then "Marie Curie" should be a member of "My Community"

  @selenium
  Scenario: approve a task to accept a member as member in a closed community through notification
    Given "Marie Curie" asked to join "My Community"
    And I am logged in as "mario"
    And I go to mycommunity's control panel
    And I follow "menu-toggle"
    And I should see "Marie Curie wants to be a member"
    When I follow "Accept"
    And I wait for 1 seconds
    Then "Marie Curie" should be a member of "My Community"

  @selenium
  Scenario: approve a member as moderator in a closed community
    Given "Marie Curie" asked to join "My Community"
    And I am logged in as "mario"
    And I follow "menu-toggle"
    And I should see "Marie Curie wants to be a member of 'My Community'."
    When I follow "Accept"
    Given I am on /myprofile/mycommunity
    And I follow "Manage Members"
    And I fill in "Name or Email" with "Marie Curie"
    And I follow "Search"
    And I should see "Marie Curie"
    And I follow "Edit"
    And I check "Moderator"
    And I follow "Save changes"
    Then "Marie Curie" should be moderator of "My Community"
