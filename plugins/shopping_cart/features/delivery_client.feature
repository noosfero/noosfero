Feature: delivery client
  As an enterprise's client
  I want to choose the delivery method
  In order to receive my procucts properly

  Background:
    Given "ShoppingCart" plugin is enabled
    And "Delivery" plugin is enabled
    And the following users
      | login | name  | email                 |
      | moe   | Moe   | moe@springfield.com   |
      | homer | Homer | homer@springfield.com |
    And the following enterprise
      | identifier  | name        | owner |
      | moes-tavern | Moes Tavern | moe |
    And the shopping basket is enabled on "Moes Tavern"
    And the following product_categories
      | name        |
      | Beer        |
      | Snacks      |
    And the following products
      | owner       | category    | name                        | price |
      | moes-tavern | beer        | Duff                        | 3.00  |
      | moes-tavern | snacks      | French fries                | 7.00  |
    And "moes-tavern" has the following delivery methods
      | delivery_type    | name | description                  | fixed_cost   | free_over_price |
      | deliver | Bike | My good old bike.                     | 8.00         | 10.00           |
      | pickup  | Bar  | Come to my bar and drink it!          | 0.00         | 0.00            |
    And feature "products_for_enterprises" is enabled on environment
    And I am logged in as "homer"
    And I go to moes-tavern's products page

  @selenium
  Scenario: choose deliver method for purchase
    Given I follow "Add to basket"
    And I follow "Add to basket"
    And I should see "Show basket"
    And I follow "Show basket"
    And I follow "Shopping checkout"
    And I fill in "Contact phone" with "123456789"
    When I select "Bike ($8.00)" from "Option"
    Then I should see "My good old bike." within ".instructions"
    And I should see "Address"
    And I should see "Bike" within "#delivery-name"
    And I should see "8.00" within "#delivery-price"

  @selenium
  Scenario: choose pickup method for purchase
    Given I follow "Add to basket"
    And I follow "Add to basket"
    And I should see "Show basket"
    And I follow "Show basket"
    And I follow "Shopping checkout"
    And I fill in "Contact phone" with "123456789"
    When I select "Bar" from "Option"
    Then I should see "Come to my bar and drink it!" within ".instructions"
    And I should not see "Address"
    And I should see "Bar" within "#delivery-name"
    And I should see "0.00" within "#delivery-price"

  @selenium
  Scenario: gets free delivery due to free over price
    Given I follow "Add to basket"
    And I follow "Add to basket"
    And I follow "Add to basket"
    And I follow "Add to basket"
    And I follow "Add to basket"
    And I follow "Add to basket"
    And I should see "Show basket"
    And I follow "Show basket"
    And I follow "Shopping checkout"
    And I fill in "Contact phone" with "123456789"
    When I select "Bike ($8.00)" from "Option"
    Then I should see "My good old bike." within ".instructions"
    And I should see "Address"
    And I should see "Bike" within "#delivery-name"
    And I should see "0.00" within "#delivery-price"
