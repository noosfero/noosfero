Feature: create article
  As a noosfero user
  I want to create new articles

  Background:
    Given I am on the homepage
    And the following users
      | login | name |
      | joaosilva | Joao Silva |
    And I am logged in as "joaosilva"

  Scenario: create a folder
    Given I am on Joao Silva's control panel
    And I follow "Manage Content"
    When I follow "New Folder"
    And I fill in "Title" with "My Folder"
    And I press "Save"
    And I go to Joao Silva's control panel
    Then I should see "My Folder"

  Scenario: redirect to the created folder
    Given I am on Joao Silva's control panel
    And I follow "Manage Content"
    When I follow "New Folder"
    And I fill in "Title" with "My Folder"
    And I press "Save"
    Then I should see "Content management"
	And I should be on Joao Silva's cms

  Scenario: cancel button back to cms
    Given I follow "Control panel"
    And I follow "Manage Content"
    And I follow "New Folder"
    When I follow "Cancel"
    Then I should be on Joao Silva's cms
