Feature: search people
  As a noosfero user
  I want to search people
  In order to find ones that interest me

  Background:
    Given the following users
      | login      | name        |
      | joaosilva  | Joao Silva  |
      | josearaujo | Jose Araujo |

  Scenario: show recent people on index (empty query)
    When I go to the search people page
    Then I should see "Joao Silva" within "#search-results"
    And I should see "Jose Araujo" within "#search-results"

  Scenario: simple search for person
    When I go to the search people page
    And I fill in "search-input" with "Silva"
    And I press "Search"
    Then I should see "Joao Silva" within "#search-results"
    And I should see "Joao Silva" within ".only-one-result-box"
    And I should not see "Jose Araujo"

  Scenario: show empty search results
    When I search people for "something unrelated"
    Then I should see "None" within ".search-results-type-empty"

  Scenario: find person without exact query
    Given the following users
      | login  | name                             |
      | jsilva | Joao Adalberto de Oliveira Silva |
    When I go to the search people page
    And I fill in "search-input" with "Adalberto de Oliveira"
    And I press "Search"
    Then I should see "Joao Adalberto de Oliveira Silva" within "#search-results"
