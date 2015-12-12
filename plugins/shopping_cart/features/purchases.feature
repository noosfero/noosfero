Feature: purchases
  As an enterprise's client
  I want to view my purchases
  In order to manage the products I bought

  Background:
    Given "ShoppingCart" plugin is enabled
    And "Orders" plugin is enabled
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
    And feature "products_for_enterprises" is enabled on environment
    And I am logged in as "homer"
    And I am on homer's control panel

  @selenium
  Scenario: view orders
    Given the following purchase from "homer" on "moes-tavern" that is "ordered"
      | product      | quantity | price |
      | Duff         | 3        | 3.50  |
      | French fries | 1        | 7.00  |
    When I follow "Purchases made"
    Then I should see "Moes Tavern" within any ".actor-name"
    And I should see "17.50" within any ".total"
    And I should see "Ordered" within any ".situation"

  @selenium
  Scenario: view orders with different status
    Given the following purchase from "homer" on "moes-tavern" that is "accepted"
      | product      | quantity | price |
      | Duff         | 2        | 3.50  |
    And the following purchase from "homer" on "moes-tavern" that is "delivered"
      | product              | quantity | price |
      | French fries         | 1        | 7.00  |
    When I follow "Purchases made"
    Then I should see "Accepted" within any ".situation"
    And I should see "Delivered" within any ".situation"

  @selenium
  Scenario: filter orders by situation
    Given the following purchase from "homer" on "moes-tavern" that is "accepted"
      | product      | quantity | price |
      | Duff         | 2        | 3.50  |
    And the following purchase from "homer" on "moes-tavern" that is "delivered"
      | product              | quantity | price |
      | French fries         | 1        | 7.00  |
    And I follow "Purchases made"
    And I should see "Accepted" within any ".situation"
    And I should see "Delivered" within any ".situation"
    And I select "Delivered" from "status"
    When I press "Filter"
    Then I should not see "Accepted" within any ".situation"
    And I should see "Delivered" within any ".situation"


  @selenium
  Scenario: filter orders by code
    Given the following purchase from "homer" on "moes-tavern" that is "ordered"
      | product      | quantity | price |
      | Duff         | 2        | 3.50  |
    And the following purchase from "homer" on "moes-tavern" that is "ordered"
      | product              | quantity | price |
      | French fries         | 1        | 7.00  |
    And I follow "Purchases made"
    And I should see "1" within any ".code"
    And I should see "2" within any ".code"
    And I fill in "code" with "2"
    When I press "Filter"
    Then I should not see "1" within any ".code"
    Then I should see "2" within any ".code"


  @selenium
  Scenario: filter orders by supplier
    Given the following users
      | login     | name               | email                 |
      | lovejoy   | Reverend Lovejoy   | lovejoy@springfield.com   |
    And the following enterprise
      | identifier                  | name                        | owner     |
      | first-church-of-springfield | First Church of Springfield | lovejoy   |
    And the shopping basket is enabled on "First Church of Springfield"
    And the following product_categories
      | name        |
      | Holy        |
    And the following products
      | owner                       | category    | name | price |
      | first-church-of-springfield | holy        | Wine | 5.00  |
    And the following purchase from "homer" on "moes-tavern" that is "ordered"
      | product              | quantity | price |
      | French fries         | 1        | 7.00  |
    And the following purchase from "homer" on "first-church-of-springfield" that is "ordered"
      | product      | quantity | price  |
      | Wine         | 5        | 10.50  |
    And I follow "Purchases made"
    And I should see "Moes Tavern" within any ".actor-name"
    And I should see "First Church of Springfield" within any ".actor-name"
    And I select "Moes Tavern" from "supplier_id"
    When I press "Filter"
    Then I should see "Moes Tavern" within any ".actor-name"
    And I should not see "First Church of Springfield" within any ".actor-name"

  @selenium
  Scenario: products checkout
    Given "moes-tavern" has the following delivery methods
      | delivery_type    | name | description                  | fixed_cost   | free_over_price |
      | deliver | Bike | My good old bike.                     | 8.00         | 10.00           |
      | pickup  | Bar  | Come to my bar and drink it!          | 0.00         | 0.00            |
    And I am on moes-tavern's products page
    And I follow "Add to basket"
    And I follow "Add to basket"
    And I follow "Add to basket"
    And I follow "Show basket"
    And I follow "Shopping checkout"
    And I fill in "order_consumer_data_contact_phone" with "123456789"
    And I select "Bike ($8.00)" from "Option"
    And I press "Send buy request"
    And I go to homer's control panel
    When I follow "Purchases made"
    Then I should see "Moes Tavern" within any ".actor-name"

  # FIXME: repeat only appear on the new catalog
  @selenium-fixme
  Scenario: repeat order
    Given "moes-tavern" has the following delivery methods
      | delivery_type    | name | description                  | fixed_cost   | free_over_price |
      | deliver | Bike | My good old bike.                     | 8.00         | 10.00           |
      | pickup  | Bar  | Come to my bar and drink it!          | 0.00         | 0.00            |
    And the following purchase from "homer" on "moes-tavern" that is "ordered"
      | product      | quantity | price |
      | Duff         | 3        | 3.50  |
      | French fries | 1        | 7.00  |
    And I am on moes-tavern's products page
    And I follow "Add to basket"
    And I follow "Add to basket"
    And I follow "Show basket"
    And I follow "Hide basket"
    When I follow "checkout"
    Then I should see "Shopping checkout"
    And I should see "Duff"
    And I should see "French fries"
