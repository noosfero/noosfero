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
    Given I follow "Edit sideboxes"
    And I follow "Edit" within ".link-list-block"
    When I follow "New link"
    Then the "css=div.icon-selector" should not be visible
    When I click ".icon"
    Then the "css=div.icon-selector" should be visible
