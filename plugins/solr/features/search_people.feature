Feature: search people
  As a noosfero user
  I want to search people
  In order to find ones that interest me

  Background:
    Given the search index is empty
    And plugin Solr is enabled on environment
    And the following users
      | login      | name        |
      | joaosilva  | Joao Silva  |
      | josearaujo | Jose Araujo |

  Scenario: see category facets when searching
    Given the following categories as facets
      | name      |
      | Temáticas |
    When I go to the search people page
    And I fill in "search-input" with "joao"
    And I press "Search"
    Then I should see "Temáticas" within "#facets-menu"

  Scenario: search people by category
    Given the following category
      | name           |
      | Software Livre |
    And the following users
      | login | name           | category       |
      | linus | Linus Torvalds | software-livre |
    When I go to the search people page
    And I fill in "search-input" with "software livre"
    And I press "Search"
    Then I should see "Linus Torvalds" within "#search-results"
    And I should not see "Joao Silva"
    And I should not see "Jose Araujo"

  Scenario: find person without exact query
    Given the following users
      | login  | name                             |
      | jsilva | Joao Adalberto de Oliveira Silva |
    When I go to the search people page
    And I fill in "search-input" with "Adalberto Silva"
    And I press "Search"
    Then I should see "Joao Adalberto de Oliveira Silva" within "#search-results"

    Given the following categories as facets
      | name      |
      | Temáticas |
    And the following category
      | name           | parent    |
      | Software Livre | tematicas |
    And the following users
      | login | name           | category       |
      | linus | Linus Torvalds | software-livre |
      | other | Other Linus    |                |
    When I go to the search people page
    And I fill in "search-input" with "Linus"
    And I press "Search"
    And I follow "Software Livre" within "#facets-menu"
    Then I should see "Linus Torvalds" within "#search-results"
    And I should not see "Other Linus"
    # facet should also be de-selectable
    When I follow "remove facet" within ".facet-selected"
    Then I should see "Other Linus"

  Scenario: remember facet filter when searching new query
    Given the following categories as facets
      | name      |
      | Temáticas |
    And the following category
      | name           | parent    |
      | Software Livre | tematicas |
    And the following users
      | login | name             | category       |
      | linus | Linus Torvalds   | software-livre |
      | rilin | Richard Linus    |                |
      | stall | Richard Stallman | software-livre |
    When I go to the search people page
    And I fill in "search-input" with "Linus"
    And I press "Search"
    And I follow "Software Livre" within "#facets-menu"
    And I fill in "search-input" with "Richard"
    And I press "Search"
    Then I should see "Richard Stallman" within "#search-results"
    And I should not see "Richard Linus"

