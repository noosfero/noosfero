Feature: featured_products_block
  As a profile owner
  I want to edit the featured block

  Background:
    Given I am on the homepage
    And the following users
      | login       | name         |
      | eddievedder | Eddie Vedder |
    And the following enterprises
      | identifier | owner | name | enabled |
      | redemoinho | eddievedder | Rede Moinho | true |
    And the following blocks
      | owner       | type          |
      | redemoinho | FeaturedProductsBlock |
    And the following product_category
      | name |
      | automobile |
    And the following products
      | owner      | category | name | description | highlighted |
      | redemoinho | automobile  | Car | Red Car | true |
      | redemoinho | automobile  | Truck | Blue Truck | true |
    And I am logged in as "eddievedder"

  @selenium
  Scenario: select a product to be featured
    And I follow "Manage my groups"
    And I follow "Control panel of this group"
    And I follow "Edit sideboxes"
    Given I follow "Edit" within ".featured-products-block"
    And I select "Car"
    When I press "Save"
    Then I should see "Car"
    And I should not see "float_to_currency"
    And I should not see "product_path"
