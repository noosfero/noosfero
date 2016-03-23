Feature: manage tasks
  As an community admin user
  I want to manage pending tasks
  In order to approve or disapprove them

  Background:
    Given the following users
      | login | name        | email            |
      | bob   | Bob Rezende | bob@invalid.br   |
      | maria | Maria Sousa | maria@invalid.br |
      | marie | Marie Curie | marie@invalid.br |
      | mario | Mario Souto | mario@invalid.br |
    And the following community
      | identifier  | name         |
      | mycommunity | My Community |
    And the community "My Community" is closed
    And the articles of "My Community" are moderated
    And "Bob Rezende" is admin of "My Community"
    And "Mario Souto" is a member of "My Community"

  @selenium
  Scenario: keep filters after close tasks
    Given "Marie Curie" asked to join "My Community"
    And "Maria Sousa" asked to join "My Community"
	And someone suggested the following article to be published
	  |name             | target      | email            | body  | person |
      |Sample Article   | mycommunity | mario@invalid.br | Corpo | mario  |
      |Other Article    | mycommunity | maria@invalid.br | Corpo | maria  |
      |Another Article  | mycommunity | marie@invalid.br | Corpo | marie  |
    And I am logged in as "bob"
    And I go to mycommunity's control panel
    And I follow "Tasks"
    And I should see "Marie Curie wants to be a member of 'My Community'"
    And I should see "Maria Sousa wants to be a member of 'My Community'"
    And I should see "Mario Souto suggested the publication of the article: Sample Article"
    And I should see "Maria Sousa suggested the publication of the article: Other Article"
    And I should see "Marie Curie suggested the publication of the article: Another Article"
    When I select "New member" from "Type of task"
    And I press "Search"
    And I should see "wants to be a member of 'My Community'"
    And I should not see "suggested the publication of the article:"
    And I choose "Accept"
    And I press "Apply"
    And I should see "wants to be a member of 'My Community'"
    Then I should not see "suggested the publication of the article:"
