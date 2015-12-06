Feature: delivery administration
  As an enterprise's administrator
  I want to create delivery methods
  In order to allow my customer to choose which delivery they want

  Background:
    Given "ShoppingCart" plugin is enabled
    And "Delivery" plugin is enabled
    And the following users
      | login | name |
      | moe | Moe |
    And the following enterprise
      | identifier  | name        | owner |
      | moes-tavern | Moes Tavern | moe |
    And the shopping basket is enabled on "Moes Tavern"
    And "Moe" is admin of "Moes Tavern"
    And I am logged in as "moe"
    And I go to moes-tavern's control panel

  @selenium
  Scenario: enable delivery
    Given I follow "Shopping basket"
    When I check "Enable shopping basket"
    Then I should see "Deliveries or pickups"

  @selenium
  Scenario: disable delivery
    Given I follow "Shopping basket"
    When I uncheck "Enable shopping basket"
    Then I should not see "Deliveries or pickups"

  @selenium
  Scenario: create new deliver
    Given I follow "Shopping basket"
    And I check "Enable shopping basket"
    And I follow "New delivery or pickup"
    And I select "Deliver" from "Type"
    And I fill in "Name" with "Bike"
    And I fill in "Fixed cost" with "8.00"
    And I fill in "delivery_method_free_over_price" with "35.50"
    When I press "Add"
    Then I should see "Bike" within ".delivery-method"

  @selenium
  Scenario: create new pickup
    Given I follow "Shopping basket"
    And I check "Enable shopping basket"
    And I follow "New delivery or pickup"
    And I select "Pickup" from "Type"
    And I fill in "Name" with "Bar"
    And I fill in "Fixed cost" with "0.00"
    When I press "Add"
    Then I should see "Bar"

  @selenium
  Scenario: remove delivery
    Given I follow "Shopping basket"
    And I check "Enable shopping basket"
    And I follow "New delivery or pickup"
    And I fill in "Name" with "Bike"
    When I press "Add"
    Then I should see "Bike"
    And I follow "Remove" within ".delivery-method"
    When I confirm the browser dialog
    Then I should see "Bike"

  @selenium
  Scenario: edit delivery
    Given I follow "Shopping basket"
    And I check "Enable shopping basket"
    And I follow "New delivery or pickup"
    And I fill in "Name" with "Bike"
    When I press "Add"
    Then I should see "Bike"
    And I follow "Edit" within ".delivery-method"
    And I fill in "Name" with "Car"
    When I press "Save"
    Then I should not see "Bike"
    Then I should see "Car"
