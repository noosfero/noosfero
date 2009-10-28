Feature: search
  As a noosfero user
  I want to search
  In order to find stuff

  Scenario: simple search for person
    Given I am on the homepage
    And the following users
      | login | name |
      | joaosilva | Joao Silva |
      | josearaujo | Jose Araujo |
    When I follow "Search"
    And I fill in "query" with "Silva"
    And I press "Search"
    Then I should see "Joao Silva"
    And I should not see "Jose Araujo"

  Scenario: simple search for community
    Given I am on the homepage
    And the following communities
      | identifier | name |
      | boring-community | Boring community |
      | fancy-community | Fancy community |
    And I follow "Search"
    And I fill in "query" with "fancy"
    And I press "Search"
    Then I should see "Fancy community"
    And I should not see "Boring community"

  Scenario: simple search for enterprise
    Given I am on the homepage
    And the following enterprises
      | identifier | name |
      | products-factory | Products factory |
      | services-provider | Services Provider |
    And I follow "Search"
    And I fill in "query" with "services"
    And I press "Search"
    Then I should see "Services Provider"
    And I should not see "Products factory"

  Scenario: simple search for content
    Given the following users
      | login     | name       |
      | joaosilva | Joao Silva |
    And the following articles
      | owner     | name                 | body |
      | joaosilva | bees and butterflies | this is an article about bees and butterflies |
      | joaosilva | whales and dolphins | this is an article about whales and dolphins |
    And I am on the homepage
    When I follow "Search"
    And I fill in "query" with "whales"
    And I press "Search"
    Then I should see "whales and dolphins"
    And I should not see "bees and butterflies"


  Scenario: simple search for product
    Given the following enterprises
      | identifier | name |
      | colivre-ent | Colivre |
    And the following products
      | owner | name |
      | colivre-ent | social networks consultancy |
      | colivre-ent | wikis consultancy |
    And I am on the homepage
    When I follow "Search"
    And I fill in "query" with "wikis"
    And I press "Search"
    Then I should see "wikis consultancy"
    And I should not see "social networks consultancy"


  Scenario: simple search for event
    Given the following communities
      | identifier | name |
      | nice-people | Nice people |
    And the following events
      | owner | name |
      | nice-people | Group meeting |
      | nice-people | John Doe's birthday |
    And I am on the homepage
    When I follow "Search"
    And I fill in "query" with "birthday"
    And I press "Search"
    Then I should see "John Doe's birthday"
    And I should not see "Group meeting"

