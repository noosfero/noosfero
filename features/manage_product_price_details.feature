Feature: manage product price details
  As an enterprise owner
  I want to manage the details of product's price

  Background:
    Given the following users
      | login | name |
      | joaosilva | Joao Silva |
    And the following enterprises
      | identifier | owner | name | enabled |
      | redemoinho | joaosilva | Rede Moinho | true |
    Given the following product_category
      | name  |
      | Music |
    And the following product_categories
      | name | parent  |
      | Rock | music   |
      | CD Player | music   |
    And the following product
      | owner      | category | name       | price |
      | redemoinho | rock     | Abbey Road | 80.0  |
    And feature "disable_products_for_enterprises" is disabled on environment
    And the following inputs
      | product    | category  | price_per_unit | amount_used |
      | Abbey Road | Rock      | 10.0           | 2           |
      | Abbey Road | CD Player | 20.0           | 2           |
    And the following production cost
      | name  | owner       |
      | Taxes | environment |
    And I am logged in as "joaosilva"

  @selenium
  Scenario: list total value of inputs as price details
    Given I go to Rede Moinho's page of product Abbey Road
    And I follow "Price composition"
    And I follow "Describe here the cost of production"
    Then I should see "Inputs"
    And I should see "60.0" within ".inputs-cost"

  @selenium
  Scenario: return to product after save
    Given I go to Rede Moinho's page of product Abbey Road
    And I follow "Price composition"
    And I follow "Describe here the cost of production"
    And I press "Save"
    Then I should be on Rede Moinho's page of product Abbey Road

  @selenium
  Scenario: add first item on price details
    Given I go to Rede Moinho's page of product Abbey Road
    And I follow "Price composition"
    And I follow "Describe here the cost of production"
    And I follow "New cost"
    And I select "Taxes" from "price_details__production_cost_id" within "#display-product-price-details"
    And I fill in "$" with "5.00"
    And I leave the "#price_details__price" field
    And I press "Save"
    Then I should not see "Save"
    And I should see "Describe here the cost of production"

  @selenium
  Scenario: edit a production cost
    Given the following production cost
      | name  | owner       |
      | Energy | environment |
    When I go to Rede Moinho's page of product Abbey Road
    And I follow "Price composition"
    And I follow "Describe here the cost of production"
    And I follow "New cost"
    And I select "Taxes" from "price_details__production_cost_id" within "#display-product-price-details"
    And I fill in "$" with "20.00"
    And I leave the ".price-details-price" field
    And I press "Save"
    Then I should not see "Save"
    And I should see "Taxes" within "#display-price-details"
    When I follow "Describe here the cost of production"
    And I select "Energy" from "price_details__production_cost_id" within "#display-product-price-details"
    And I leave the "#price_details__price" field
    And I press "Save"
    And I should not see "Taxes" within "#display-price-details"
    And I should see "Energy" within "#display-price-details"

  Scenario: not display price composition if product does not have input
    Given the following product
      | owner      | category | name             |
      | redemoinho | rock     | Yellow Submarine |
    And the following user
      | login      | name        |
      | mariasouza | Maria Souza |
    And I am logged in as "mariasouza"
    When I go to Rede Moinho's page of product Yellow Submarine
    Then I should not see "Price composition"

  Scenario: not display price composition if price is not fully described
    Given I am not logged in
    And I go to Rede Moinho's page of product Abbey Road
    Then I should not see "Price composition"

   @selenium
   Scenario: display price details if price is fully described
     Given I go to Rede Moinho's page of product Abbey Road
     And I follow "Price composition"
     And I follow "Describe here the cost of production"
     And I follow "New cost"
     And I select "Taxes" from "price_details__production_cost_id" within "#display-product-price-details"
     And I fill in "$" with "20.00"
     And I press "Save"
     And I go to Rede Moinho's page of product Abbey Road
     Then I should see "Inputs" within ".price-detail-name"
     And I should see "60.0" within ".price-detail-price"

  @selenium
  Scenario: create a new cost clicking on select
    Given I go to Rede Moinho's page of product Abbey Road
    And I follow "Price composition"
    And I follow "Describe here the cost of production"
    And I follow "New cost"
    And I select "Other cost" from "price_details__production_cost_id" within "#display-product-price-details"
    And I want to add "Energy" as cost
    And I fill in "$" with "10.00"
    And I leave the "#price_details__price" field
    And I press "Save"
    When I follow "Describe here the cost of production"
    Then I should see "Energy" within ".production-cost-selection"

  @selenium
  Scenario: add created cost on new-cost-fields
    Given I go to Rede Moinho's page of product Abbey Road
    And I follow "Price composition"
    And I follow "Describe here the cost of production"
    And I follow "New cost"
    And I select "Other cost" from "price_details__production_cost_id" within "#display-product-price-details"
    And I want to add "Energy" as cost
    Then I should see "Energy" within "#display-product-price-details"

  @selenium
  Scenario: remove price detail
    Given the following price detail
      | product    | production_cost | price |
      | Abbey Road | Taxes           | 20.0  |
    And I go to Rede Moinho's page of product Abbey Road
    And I follow "Price composition"
    And I follow "Describe here the cost of production"
    And I should see "Taxes" within "#manage-product-details-form"
    When I follow "Remove" within "#manage-product-details-form"
    And I confirm the browser dialog
    And I press "Save"
    And I follow "Describe here the cost of production"
    Then I should not see "Taxes" within "#manage-product-details-form"

  Scenario: display progressbar
    Given I go to Rede Moinho's page of product Abbey Road
    And I follow "Price composition"
    And I follow "Describe here the cost of production"
    Then I should see "$ 60.00 of $ 80.00" within "#progressbar-text"

  @selenium
  Scenario: update value on progressbar after addition of new cost
    Given I go to Rede Moinho's page of product Abbey Road
    And I follow "Price composition"
    And I follow "Describe here the cost of production"
    Then I should see "$ 60.00 of $ 80.00" within "#progressbar-text"
    And I follow "New cost"
    And I fill in "$" with "10.00"
    And I leave the "#price_details__price" field
    Then I should see "$ 70.00 of $ 80.00" within "#progressbar-text"

  @selenium
  Scenario: update value on progressbar after editing an input
    Given I go to Rede Moinho's page of product Abbey Road
    And I follow "Price composition"
    And I follow "Describe here the cost of production"
    Then I should see "$ 60.00 of $ 80.00" within "#progressbar-text"
    When I follow "Inputs"
    And I follow "Edit" within ".input-details"
    And I fill in "Price" with "23.31"
    And I press "Save"
    Then I follow "Price composition"
    And I should see "$ 86.62 of $ 80.00" within "#progressbar-text"
