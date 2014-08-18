Feature: Edit Highlight Block
  As a user
  I want to edit the highlight block

  Background:
    Given I am on the homepage
    And the following users
      | login       | name         |
      | jose        | Jose Silva   |
    And I am logged in as "jose"

  @selenium
  Scenario: Add new highlight
    Given I follow "Control panel"
    And I follow "Edit sideboxes"
    And I follow "Add a block"
    And I choose "Highlights"
    And I press "Add"
    And I follow "Edit" within ".highlights-block"#Need to hover the mouse on the box
    And I follow "New highlight"
    And I fill in "block_images__address" with "/"
    And I fill in "block_images__position" with "0"
    And I fill in "block_images__title" with "test highlights"
    And I press "Save"
    And I follow "Edit" within ".highlights-block"
    Then I should see "Title"

  @selenium-fixme
  Scenario: Remove one saved highlight
    Given I follow "Control panel"
    And I follow "Edit sideboxes"
    And I follow "Add a block"
    And I choose "Highlights"
    And I press "Add"
    And I follow "Edit" within ".highlights-block"
    And I follow "New highlight"
    And I fill in "block_images__address" with "/"
    And I fill in "block_images__position" with "0"
    And I fill in "block_images__title" with "test highlights"#Need to hover the mouse on the box
    And I press "Save"
    And I follow "Edit" within ".highlights-block"
    And I follow "" within ".delete-highlight"
    And I confirm the browser dialog
    Then I should not see "Title"