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
    And I follow "Community Info and settings"
    And I check "Secret"
    And I follow "Save"
    And I follow "menu-dropdown"
    And I follow "Logout"
    And I go to /account/login

  @selenium
  Scenario: Hide privacity options when secret is checked
    Given I am logged in as "jose"
    And I go to mycommunity's control panel
    And I follow "Community Info and settings"
    Then I should not see "Public — show content of this group to all internet users"
    And I should not see "Private — show content of this group only to members"
    And I uncheck "Secret"
    Then I should see "Public — show content of this group to all internet users"
    Then I should see "Private — show content of this group only to members"

  @selenium
  Scenario: Non members shouldn't see secret communit's content
    Given I am logged in as "maria"
    And I go to mycommunity's homepage
    And I should see "Oops ... You Cannot Go Ahead Here This profile is inaccessible. You don't have the permission to view the content here. Go back Go to the home page Manual This social network uses Noosfero, developed by Colivre and licensed under the GNU Affero General Public License version 3 or any later version."
    And I go to /search/communities
    Then I should not see "My Community"

  Scenario: A member should see the secret community's content
    Given I am logged in as "maria"
    And "Maria Carminha" is a member of "My Community"
    And I go to maria's control panel
    And I follow "Manage my groups"
    And I follow "My Community"
    Then I should see "My Community"

  @selenium
  Scenario: public article on a secret profile should not be displayed
    Given I am logged in as "jose"
    And I go to mycommunity's control panel
    And I follow "Manage Content"
    And I follow "New content"
    And I follow "Text article"
    And I fill in "Title" with "My public article"
    And I choose "Public"
    And I follow "Save"
    When I am logged in as "maria"
    And I go to /mycommunity/my-public-article
    Then I should not see "My public article"
