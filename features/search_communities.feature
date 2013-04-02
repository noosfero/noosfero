Feature: search communities
  As a noosfero user
  I want to search communities
  In order to find ones that interest me

  Background:
    Given the search index is empty
    And the following category
      | name           |
      | social network |
    And the following community
      | identifier | name               | category       | img              |
      | noosfero   | Noosfero Community | social-network | noosfero-network |

  Scenario: show recent communities on index
    Given the following community
      | identifier | name            | category       | img |
      | linux      | Linux Community | social-network | tux |
    When I go to the search communities page
    Then I should see "Noosfero Community" within "#search-results"
    And I should see Noosfero Community's community image
    And I should see "Linux Community" within "#search-results"
    And I should see Linux Community's community image

  Scenario: show empty search results
    When I search communities for "something unrelated"
    Then I should see "None" within ".search-results-type-empty"

  Scenario: simple search for community
    When I go to the search communities page
    And I fill in "search-input" with "noosfero"
    And I press "Search"
    Then I should see "Noosfero Community" within "#search-results"
    And I should see "Noosfero Community" within ".only-one-result-box"
    And I should see Noosfero Community's community image

  Scenario: search communities by category
    Given the following category
      | name           |
      | Software Livre |
    And the following community
      | identifier | name               | category       |
      | noos-comm  | Noosfero Community | software-livre |
    When I go to the search communities page
    And I fill in "search-input" with "software livre"
    And I press "Search"
    Then I should see "Noosfero" within "#search-results"

  Scenario: see category facets when searching
    Given the following categories as facets
      | name      |
      | Temáticas |
    And the following category
      | name           | parent    |
      | Software Livre | tematicas |
    And the following community
      | identifier | name            | category       |
      | linux      | Linux Community | software-livre |
    When I go to the search communities page
    And I fill in "search-input" with "Linux"
    And I press "Search"
    Then I should see "Temáticas" within "#facets-menu"

  Scenario: find communities without exact query
    Given the following communities
      | identifier | name                       |
      | luwac      | Linux Users Without a Clue |
    When I go to the search communities page
    And I fill in "search-input" with "Linux Clue"
    And I press "Search"
    Then I should see "Linux Users Without a Clue" within "#search-results"

  Scenario: filter communities by facet
    Given the following categories as facets
      | name      |
      | Temáticas |
    And the following category
      | name           | parent    |
      | Software Livre | tematicas |
      | Big Brother    | tematicas |
    And the following communities
      | identifier | name                | category       |
      | noos-dev   | Noosfero Developers | software-livre |
      | facebook   | Facebook Developers | big-brother    |
    When I go to the search communities page
    And I fill in "search-input" with "Developers"
    And I press "Search"
    And I follow "Software Livre" within "#facets-menu"
    Then I should see "Noosfero Developers" within "#search-results"
    And I should not see "Facebook Developers"
    # facet should also be de-selectable
    When I follow "remove facet" within ".facet-selected"
    Then I should see "Facebook Developers"

  Scenario: remember facet filter when searching new query
    Given the following categories as facets
      | name      |
      | Temáticas |
    And the following category
      | name           | parent    |
      | Software Livre | tematicas |
      | Other Category | tematicas |
    And the following communities
      | identifier | name                | category       |
      | noos-dev   | Noosfero Developers | software-livre |
      | rails-dev  | Rails Developers    | other-category |
      | rails-usr  | Rails Users         | software-livre |
    When I go to the search communities page
    And I fill in "search-input" with "Developers"
    And I press "Search"
    And I follow "Software Livre" within "#facets-menu"
    And I fill in "search-input" with "Rails"
    And I press "Search"
    Then I should see "Rails Users" within "#search-results"
    And I should not see "Rails Developers"
