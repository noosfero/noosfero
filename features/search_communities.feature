Feature: search communities
  As a noosfero user
  I want to search communities
  In order to find ones that interest me

  Background:
    Given plugin Solr is enabled on environment
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

  Scenario: find communities without exact query
    Given the following communities
      | identifier | name                       |
      | luwac      | Linux Users Without a Clue |
    When I go to the search communities page
    And I fill in "search-input" with "Linux Users"
    And I press "Search"
    Then I should see "Linux Users Without a Clue" within "#search-results"
