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
  Scenario: approve a task to accept a member as admin in a closed community
    Given "Marie Curie" asked to join "My Community"
    And I am logged in as "mario"
    And I go to mycommunity's control panel
    And I follow "Process requests"
    And I should see "Marie Curie wants to be a member"
    When I choose "Accept"
    And I check "Profile Administrator"
    And I press "Apply!"
    Then "Marie Curie" should be admin of "My Community"

  @selenium
  Scenario: approve a task to accept a member as member in a closed community
    Given "Marie Curie" asked to join "My Community"
    And I am logged in as "mario"
    And I go to mycommunity's control panel
    And I follow "Process requests"
    And I should see "Marie Curie wants to be a member"
    When I choose "Accept"
    And I check "Profile Member"
    And I press "Apply!"
    Then "Marie Curie" should be a member of "My Community"

  @selenium
  Scenario: approve a task to accept a member as moderator in a closed community
    Given "Marie Curie" asked to join "My Community"
    And I am logged in as "mario"
    And I go to mycommunity's control panel
    And I follow "Process requests"
    And I should see "Marie Curie wants to be a member"
    When I choose "Accept"
    And I check "Profile Moderator"
    And I press "Apply!"
    Then "Marie Curie" should be moderator of "My Community"
