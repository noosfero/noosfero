Feature: edit_block_of_links
  As a profile owner
  I want to edit a block of links

  Background:
    Given I am on the homepage
    And the following users
      | login       | name         |
      | eddievedder | Eddie Vedder |
    And the following blocks
      | owner       | type          |
      | eddievedder | LinkListBlock |
    And I am logged in as "eddievedder"

  @selenium
  Scenario: show the icon selector
    And I follow "Edit sideboxes"
    Given I follow "Edit" within ".link-list-block"
    And I follow "New link"
    And the ".icon-selector" should not be visible
    When I click ".icon"
    Then the ".icon-selector" should be visible
