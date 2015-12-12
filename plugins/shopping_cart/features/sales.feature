Feature: sales
  As an enterprise's administrator
  I want to view my sales
  In order to manage the products I sold

  Background:
    Given "ShoppingCart" plugin is enabled
    And "Orders" plugin is enabled
    And the following users
      | login | name  | email                 |
      | moe   | Moe   | moe@springfield.com   |
      | homer | Homer | homer@springfield.com |
    And the following enterprise
      | identifier  | name        | owner |
      | moes-tavern | Moes Tavern | moe |
    And "Moe" is admin of "Moes Tavern"
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
    And I am logged in as "moe"
    And I am on moes-tavern's control panel

  @selenium
  Scenario: view orders
    Given the following purchase from "homer" on "moes-tavern" that is "ordered"
      | product      | quantity | price |
      | Duff         | 3        | 3.50  |
      | French fries | 1        | 7.00  |
    When I follow "Purchases and Sales"
    Then I should see "Homer" within any ".actor-name"
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
    When I follow "Purchases and Sales"
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
    And I follow "Purchases and Sales"
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
    And I follow "Purchases and Sales"
    And I should see "1" within any ".code"
    And I should see "2" within any ".code"
    And I fill in "code" with "2"
    When I press "Filter"
    Then I should not see "1" within any ".code"
    Then I should see "2" within any ".code"


  @selenium
  Scenario: filter orders by consumer
    Given the following users
      | login     | name               | email                 |
      | lovejoy   | Reverend Lovejoy   | lovejoy@springfield.com   |
    And the following purchase from "homer" on "moes-tavern" that is "ordered"
      | product      | quantity | price  |
      | Duff         | 5        | 10.50  |
    And the following purchase from "lovejoy" on "moes-tavern" that is "ordered"
      | product              | quantity | price |
      | French fries         | 1        | 7.00  |
    And I follow "Purchases and Sales"
    And I should see "Homer" within any ".actor-name"
    And I should see "Reverend Lovejoy" within any ".actor-name"
    And I select "Homer" from "consumer_id"
    When I press "Filter"
    Then I should see "Homer" within any ".actor-name"
    And I should not see "Reverend Lovejoy" within any ".actor-name"
