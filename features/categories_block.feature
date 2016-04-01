Feature: categories_block
  As an admin
  I want to manage the categories block

  Background:
    Given I am on the homepage
    And the following categories
      | name       | display_in_menu |
      | Wood       | true            |
    And the following regions
      | name       | display_in_menu |
      | Bahia       | true            |
    And the following blocks
      | owner       | type          |
      | environment | CategoriesBlock |
    And I am logged in as admin
    And I go to /admin/environment_design

  @selenium
  Scenario: List just general categories
    Given display ".button-bar"
    And I follow "Edit" within ".block-outer .categories-block"
    And I check "Generic category"
    When I press "Save"
    Then I should see "Wood"

  @selenium
  Scenario: List just regions
    Given display ".button-bar"
    And I follow "Edit" within ".block-outer .categories-block"
    And I check "Region"
    When I press "Save"
    Then I should see "Bahia"
