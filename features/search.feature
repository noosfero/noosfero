Feature: search
  As a noosfero user
  I want to search
  In order to find stuff

  Background:
    Given the search index is empty

  Scenario: simple search for person
    Given the following users
      | login | name |
      | joaosilva | Joao Silva |
      | josearaujo | Jose Araujo |
    When I go to the search page
    And I fill in "query" with "Silva"
    And I press "Search"
    Then I should see "Joao Silva"
    And I should not see "Jose Araujo"

  Scenario: simple search for community
    Given the following communities
      | identifier | name |
      | boring-community | Boring community |
      | fancy-community | Fancy community |
    And I go to the search page
    And I fill in "query" with "fancy"
    And I press "Search"
    Then I should see "Fancy community"
    And I should not see "Boring community"

  Scenario: simple search for enterprise
    Given the following enterprises
      | identifier | name |
      | shop1 | Shoes shop |
      | shop2 | Fruits shop |
    And I go to the search page
    And I fill in "query" with "shoes"
    And I press "Search"
    Then I should see "Shoes shop"
    And I should not see "Fruits shop"

  Scenario: simple search for content
    Given the following users
      | login     | name       |
      | joaosilva | Joao Silva |
    And the following articles
      | owner     | name                 | body |
      | joaosilva | bees and butterflies | this is an article about bees and butterflies |
      | joaosilva | whales and dolphins | this is an article about whales and dolphins |
    When I go to the search page
    And I fill in "query" with "whales"
    And I press "Search"
    Then I should see "whales and dolphins"
    And I should not see "bees and butterflies"


  Scenario: simple search for product
    Given the following enterprises
      | identifier | name |
      | colivre-ent | Colivre |
    And the following product_categories
      | name |
      | Development |
    And the following products
      | owner | category | name |
      | colivre-ent | development | social networks consultancy |
      | colivre-ent | development | wikis consultancy |
    When I go to the search page
    And I fill in "query" with "wikis"
    And I press "Search"
    Then I should see "wikis consultancy"
    And I should not see "social networks consultancy"


  Scenario: simple search for event
    Given the following communities
      | identifier | name |
      | nice-people | Nice people |
    And the following events
      | owner | name | start_date |
      | nice-people | Group meeting | 2009-10-01 |
      | nice-people | John Doe's birthday | 2009-09-01 |
    When I go to the search page
    And I fill in "query" with "birthday"
    And I press "Search"
    Then I should see "John Doe's birthday"
    And I should not see "Group meeting"

