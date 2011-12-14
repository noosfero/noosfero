# These tests were originally unit tests, but they were moved here since they are view tests. The originals have been kept just in case somebody wants to review them, but should be removed shortly.

Feature: enterprise homepage
  As a noosfero visitor
  I want to browse an enterprise's homepage
  In order to know more information about the enterprise

  Background:
    Given the following users
      | login       | name         |
      | durdentyler | Tyler Durden |
    And the following enterprises
      | identifier | owner       | name                  | contact_email        | contact_phone  | enabled |
      | mayhem     | durdentyler | Paper Street Soap Co. | queen@workerbees.org | (288) 555-0153 | true    |
    And the following enterprise homepage
      | enterprise | name             |
      | mayhem     | article homepage |
    And the following product_category
      | name |
      | soap |
    And the following product
      | name             | category | owner  |
      | Natural Handmade | soap     | mayhem |


  Scenario: display profile info
    When I go to /mayhem/homepage
    Then I should see "queen@workerbees.org"
    And I should see "(288) 555-0153"

  Scenario: display products list
    When I go to /mayhem/homepage
    Then I should see "Natural Handmade"

  Scenario: display link to product
    When I go to /mayhem/homepage
    And I follow "Natural Handmade"
    Then I should be taken to "Natural Handmade" product page
