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
    And I go to /admin/environment_design

  @selenium
  Scenario: List just product categories
    Given display ".button-bar"
    And I follow "Edit" within ".categories-block"
    And I check "Product"
    When I press "Save"
    Then I should see "Food"
    And I should see "Book"
    And "Vegetarian" should not be visible within "span#category-name"
    And "Steak" should not be visible within "span#category-name"
    And "Fiction" should not be visible within "span#category-name"

  @selenium
  Scenario: Show submenu if it exists
    Given display ".button-bar"
    And I follow "Edit" within ".categories-block"
    And I check "Product"
    And I press "Save"
    Then I should see "Food"
    And I should see "Book"
    And "Vegetarian" should not be visible within "span#category-name"
    And "Steak" should not be visible within "span#category-name"
    And "Literature" should not be visible within "span#category-name"
    When I follow "block_2_category_2"
    Then I should see "Literature"
    When I follow "block_2_category_1"
    Then I should see "Vegetarian"
    And I should see "Steak"
    And I should not see "Fiction"

  @selenium
  Scenario: Show only one submenu per time
    Given display ".button-bar"
    And I follow "Edit" within ".categories-block"
    And I check "Product"
    And I press "Save"
    Then I should see "Book"
    And "Literature" should not be visible within "span#category-name"
    When I follow "block_2_category_2"
    Then I should see "Literature"

  @selenium
  Scenario: List just general categories
    Given display ".button-bar"
    And I follow "Edit" within ".categories-block"
    And I check "Generic category"
    When I press "Save"
    Then I should see "Wood"

  @selenium
  Scenario: List just regions
    Given display ".button-bar"
    And I follow "Edit" within ".categories-block"
    And I check "Region"
    When I press "Save"
    Then I should see "Bahia"
