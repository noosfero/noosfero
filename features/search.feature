Feature: search
  As a noosfero user
  I want to search
  In order to find stuff

  Scenario: show empty results in all enabled assets
    Given I go to the search page
    And I fill in "search-input" with "Anything"
    And I press "Search"
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

  Scenario: simple search for person
    Given the following users
      | login      | name        |
      | joaosilva  | Joao Silva  |
      | josearaujo | Jose Araujo |
    When I go to the search people page
    And I fill in "search-input" with "Silva"
    And I press "Search"
    Then I should see "Joao Silva" within ".common-profile-list-block"
    And I should not see "Jose Araujo"

  Scenario: show link to see all results
    Given the following users
      | login      | name        |
      | joaosilva  | Joao Silva  |
    And the following articles
      | owner     | name       |
      | joaosilva | article #1 |
      | joaosilva | article #2 |
      | joaosilva | article #3 |
      | joaosilva | article #4 |
      | joaosilva | article #5 |
      | joaosilva | article #6 |
      | joaosilva | article #7 |
      | joaosilva | article #8 |
      | joaosilva | article #9 |
    When I go to the search page
    And I fill in "search-input" with "article"
    And I press "Search"
    And I should see "see all (9)"
    When I follow "see all (9)"
    Then I should be on the search articles page

  Scenario: simple search for community
    Given the following communities
      | identifier       | name             | img |
      | boring-community | Boring community | semterrinha |
      | fancy-community  | Fancy community  | agrotox |
    And I go to the search communities page
    And I fill in "search-input" with "fancy"
    And I press "Search"
    Then I should see "Fancy community" within ".common-profile-list-block"
    And I should not see "Boring community"

  Scenario: simple search for enterprise
    Given the following enterprises
      | identifier | name |
      | shop1 | Shoes shop |
      | shop2 | Fruits shop |
    And I go to the search enterprises page
    And I fill in "search-input" with "shoes"
    And I press "Search"
    Then I should see "Shoes shop" within ".common-profile-list-block"
    And I should not see "Fruits shop"

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
    And I press "Search"
    Then I should see "whales and dolphins" within "div.search-results-articles"
    And I should not see "bees and butterflies"

  Scenario: search different types of entities with the same query
    Given the following enterprises
      | identifier  | name                    |
      | colivre_dev | Colivre - Noosfero dev. |
    And the following communities
      | identifier     | name           |
      | noosfero-users | Noosfero users |
    When I go to the search page
    And I fill in "search-input" with "noosfero"
    And I press "Search"
    Then I should see "Colivre - Noosfero dev." within "div.search-results-enterprises"
    And I should see "Noosfero users" within "div.search-results-communities"
