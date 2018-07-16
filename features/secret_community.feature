Feature: Use a secret community
  As a community administrator
  I want to manage the community privacy

  Background:
    Given the following users
      | login | name           |
      | jose  | Jose Wilker    |
      | maria | Maria Carminha |
    And the following community
      | identifier  | name         |
      | mycommunity | My Community |
    And "Jose Wilker" is admin of "My Community"
    And I am logged in as "jose"
    And I go to mycommunity's control panel
    And I follow "Privacy"
    And I check "Secret"
    And I follow "Save"
    And I follow "menu-dropdown"
    And I follow "Logout"
    And I go to /account/login

  @selenium
  Scenario: Non members shouldn't see secret communit's content
    Given I am logged in as "maria"
    And I go to mycommunity's homepage
    And I should see "Oops ... you cannot go ahead here"
    And I should see "This profile is inaccessible. You don't have the permission to view the content here."
    And I go to /search/communities
    Then I should not see "My Community"

  Scenario: A member should see the secret community's content
    Given "Maria Carminha" is a member of "My Community"
    And I am logged in as "maria"
    And I am on My Community's homepage
    Then I should see "My Community"

  @selenium
  Scenario: public article on a secret profile should not be displayed
    Given I am logged in as "jose"
    And I go to mycommunity's control panel
    And I follow "New" within "#section-content"
    And I follow "Text article"
    And I fill in "Title" with "My public article"
    And I fill in post-access hidden field with "2"
    And I follow "Save and continue"
    When I am logged in as "maria"
    And I go to /mycommunity/my-public-article
    Then I should not see "My public article"
