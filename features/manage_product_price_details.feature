
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

  @selenium
  Scenario: list total value of inputs as price details
    Given I am logged in as "joaosilva"
    When I go to Rede Moinho's page of product Abbey Road
    And I follow "Describe here the cost of production"
    Then I should see "Inputs"
    And I should see "60.0" within ".inputs-cost"

  @selenium
  Scenario: cancel management of price details
    Given I am logged in as "joaosilva"
    When I go to Rede Moinho's page of product Abbey Road
    And I follow "Describe here the cost of production"
    When I follow "Cancel"
    Then I should see "Describe here the cost of production"

  @selenium
  Scenario: return to product after save
    Given I am logged in as "joaosilva"
    When I go to Rede Moinho's page of product Abbey Road
    And I follow "Describe here the cost of production"
    And I press "Save"
    Then I should be on Rede Moinho's page of product Abbey Road

  @selenium
  Scenario: add first item on price details
    Given I am logged in as "joaosilva"
    When I go to Rede Moinho's page of product Abbey Road
    And I follow "Describe here the cost of production"
    And I follow "New cost"
    And I select "Taxes"
    And I fill in "$" with "5.00"
    And I press "Save"
    Then I should not see "Save"
    And I should see "Describe here the cost of production"

  @selenium
  Scenario: edit a production cost
    Given the following production cost
      | name  | owner       |
      | Energy | environment |
    Given I am logged in as "joaosilva"
    When I go to Rede Moinho's page of product Abbey Road
    And I follow "Describe here the cost of production"
    And I follow "New cost"
    And I select "Taxes"
    And I fill in "$" with "20.00"
    And I press "Save"
    Then I should not see "Save"
    And I should see "Taxes" within "#display-price-details"
    When I follow "Describe here the cost of production"
    And I select "Energy"
    And I press "Save"
    And I should not see "Taxes" within "#display-price-details"
    And I should see "Energy" within "#display-price-details"

  Scenario: not display product detail button if product does not have input
    Given the following product
      | owner      | category | name             |
      | redemoinho | rock     | Yellow Submarine |
    And the following user
      | login      | name        |
      | mariasouza | Maria Souza |
    And I am logged in as "mariasouza"
    When I go to Rede Moinho's page of product Yellow Submarine
    Then I should not see "Describe here the cost of production"

  Scenario: not display price details if price is not fully described
    Given I go to Rede Moinho's page of product Abbey Road
    Then I should not see "60.0"

   @selenium
   Scenario: display price details if price is fully described
     Given I am logged in as "joaosilva"
     And I go to Rede Moinho's page of product Abbey Road
     And I follow "Describe here the cost of production"
     And I follow "New cost"
     And I select "Taxes"
     And I fill in "$" with "20.00"
     And I press "Save"
     Then I should see "Inputs" within ".price-detail-name"
     And I should see "60.0" within ".price-detail-price"

  @selenium
  Scenario: create a new cost clicking on select
    Given I am logged in as "joaosilva"
    And I go to Rede Moinho's page of product Abbey Road
    And I follow "Describe here the cost of production"
    And I want to add "Energy" as cost
    And I select "Other cost"
    And I press "Save"
    When I follow "Describe here the cost of production"
    Then I should see "Energy" within ".production-cost-selection"

  @selenium
  Scenario: add created cost on new-cost-fields
    Given I am logged in as "joaosilva"
    And I go to Rede Moinho's page of product Abbey Road
    And I follow "Describe here the cost of production"
    And I want to add "Energy" as cost
    And I select "Other cost"
    Then I should see "Energy" within "#new-cost-fields"

  @selenium
  Scenario: remove price detail
    Given the following price detail
      | product    | production_cost | price |
      | Abbey Road | Taxes           | 20.0  |
    And I am logged in as "joaosilva"
    And I go to Rede Moinho's page of product Abbey Road
    And I follow "Describe here the cost of production"
    And I should see "Taxes" within "#manage-product-details-form"
    When I follow "Remove" within "#manage-product-details-form"
    And I confirm
    And I press "Save"
    And I follow "Describe here the cost of production"
    Then I should not see "Taxes" within "#manage-product-details-form"
