Feature: manage categories
  As an environment administrator
  I want to manage categories

  Background:
    Given the following categories
      | name |
      | Products |
      | Services |
    And the following categories
      | name          | parent    |
      | Beans         | products  |
      | Potatoes      | products  |
      | Development   | services  |
    And I am logged in as admin
    And I am on the environment control panel
    And I follow "Categories"

  Scenario: load only top level categories
    Then I should see "Products"
    And I should see "Services"
    And I should not see "Beans"
    And I should not see "Development"

  @selenium
  Scenario: load subcategories only after following parent
    Then I should not see "Beans"
    And I should not see "Potatoes"
    When I follow "Show"
    And I wait 0.5 seconds for Services show animation to finish
    And I follow "Show"
    Then I should see "Beans"
    And I should see "Potatoes"
