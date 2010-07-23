Feature: categories_block
  As an admin
  I want to manage the categories block

  Background:
    Given I am on the homepage
    And the following product_categories
      | name       | display_in_menu |
      | Food       | true            |
      | Book       | true            |
    And the following product_categories
      | parent  | name        | display_in_menu |
      | Food    | Vegetarian  | true            |
      | Food    | Steak       | true            |
      | Book    | Fiction     | false           |
      | Book    | Literature  | true            |
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

  @selenium
  Scenario: List just product categories
    Given I go to /admin/environment_design
    And I follow "Edit" within ".categories-block"
    And I check "Product"
    When I press "Save"
    Then I should see "Food"
    And I should see "Book"
    And I should not see "Vegetarian"
    And I should not see "Steak"
    And I should not see "Fiction"

  @selenium
  Scenario: Show submenu if it exists
    Given I go to /admin/environment_design
    And I follow "Edit" within ".categories-block"
    And I check "Product"
    And I press "Save"
    Then I should see "Food"
    And I should see "Book"
    And I should not see "Vegetarian"
    And I should not see "Steak"
    And I should not see "Literature"
    When I click ".category-link-expand category-root"
    Then I should see "Literature"
    When I click ".category-link-expand category-root"
    Then I should see "Vegetarian"
    And I should see "Steak"
    And I should not see "Fiction"

  @selenium
  Scenario: Show only one submenu per time
    Given I go to /admin/environment_design
    And I follow "Edit" within ".categories-block"
    And I check "Product"
    And I press "Save"
    Then I should see "Food"
    And I should not see "Vegetarian"
    And I should not see "Steak"
    When I click ".category-link-expand category-root"
    Then I should see "Vegetarian"
    And I should see "Steak"

  @selenium
  Scenario: List just general categories
    Given I go to /admin/environment_design
    And I follow "Edit" within ".categories-block"
    And I check "Generic Category"
    When I press "Save"
    Then I should see "Wood"

  @selenium
  Scenario: List just regions
    Given I go to /admin/environment_design
    And I follow "Edit" within ".categories-block"
    And I check "Region"
    When I press "Save"
    Then I should see "Bahia"

