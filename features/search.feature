Feature: search
  As a noosfero user
  I want to search
  In order to find stuff

  @selenium
  Scenario: show empty results in all enabled assets
    Given I go to the search page
    And I fill in "search-input" with "Anything"
    And I follow "Search" within ".search-form"
    Then I should see "People" within ".search-results-people"
    And I should see "None" within ".search-results-people"
    And I should see "Communities" within ".search-results-communities"
    And I should see "None" within ".search-results-communities"
    And I should see "Enterprises" within ".search-results-enterprises"
    And I should see "None" within ".search-results-enterprises"
    And I should see "Contents" within ".search-results-articles"
    And I should see "None" within ".search-results-articles"
    And I should see "Events" within ".search-results-events"
    And I should see "None" within ".search-results-events"

  @selenium
  Scenario: simple search for person
    Given the following users
      | login      | name        |
      | joaosilva  | Joao Silva  |
      | josearaujo | Jose Araujo |
    When I go to the search people page
    And I fill in "search-input" with "Silva"
    And I follow "Search" within ".search-form"
    And I wait for 1 seconds
    Then I should see "Joao Silva" within "#search-results"
    And I should not see "Jose Araujo"

  @selenium
  Scenario: show link to see all results
    Given the following users
      | login      | name          |
      | tom1silva  | Tom1 Silva #1 |
      | tom2silva  | Tom2 Silva #2 |
      | tom3silva  | Tom3 Silva #3 |
      | tom4silva  | Tom4 Silva #4 |
      | tom5silva  | Tom5 Silva #5 |
      | tom6silva  | Tom6 Silva #6 |
      | tom7silva  | Tom7 Silva #7 |
      | tom8silva  | Tom8 Silva #8 |
      | tom9silva  | Tom9 Silva #9 |
    When I go to the search page
    And I should see "see all (9)"
    When I follow "see all (9)"
    Then I should be on the search people page

  @selenium
  Scenario: simple search for community
    Given the following communities
      | identifier       | name             | img |
      | boring-community | Boring community | semterrinha |
      | fancy-community  | Fancy community  | agrotox |
    And I go to the search communities page
    And I fill in "search-input" with "fancy"
    And I follow "Search" within ".search-form"
    And I wait for 1 seconds
    Then I should see "Fancy community" within "#search-results"
    And I should not see "Boring community"

  @selenium
  Scenario: simple search for enterprise
    Given the following enterprises
      | identifier | name |
      | shop1 | Shoes shop |
      | shop2 | Fruits shop |
    And I go to the search enterprises page
    And I fill in "search-input" with "shoes"
    And I follow "Search" within ".search-form"
    And I wait for 1 seconds
    Then I should see "Shoes shop" within "#search-results"
    And I should not see "Fruits shop"

  @selenium
  Scenario: simple search for content
    Given the following users
      | login     | name       |
      | joaosilva | Joao Silva |
    And the following articles
      | owner     | name                 | body |
      | joaosilva | bees and butterflies | this is an article about bees and butterflies |
      | joaosilva | whales and dolphins | this is an article about whales and dolphins |
    When I go to the search articles page
    And I fill in "search-input" with "whales"
    And I follow "Search" within ".search-form"
    And I wait for 1 seconds
    Then I should see "whales and dolphins" within "#search-results"
    And I should not see "bees and butterflies"

  @selenium
  Scenario: search different types of entities with the same query
    Given the following enterprises
      | identifier  | name                    |
      | colivre_dev | Colivre - Noosfero dev. |
    And the following communities
      | identifier     | name           |
      | noosfero-users | Noosfero users |
    When I go to the search page
    And I fill in "search-input" with "noosfero"
    And I follow "Search" within ".search-form"
    And I wait for 1 seconds
    Then I should see "Colivre - Noosfero dev." within "#search-results"
    And I should see "Noosfero users" within "div.search-results-communities"
