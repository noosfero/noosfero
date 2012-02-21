Feature: search enterprises
  As a noosfero user
  I want to search enterprises
  In order to find ones that interest me 

  Background:
    Given the search index is empty
    And the following enterprises
      | identifier | name        |
      | shop1      | Shoes shop  |
      | shop2      | Fruits shop |
    And the following categories as facets
      | name      |
	  | Temáticas |

  Scenario: show recent enterprises on index (empty query)
    When I go to the search enterprises page
    Then I should see "Shoes shop" within "#search-results"
    And I should see "Fruits shop" within "#search-results"

  Scenario: simple search for enterprise
    When I go to the search enterprises page
    And I fill in "query" with "shoes"
    And I press "Search"
    Then I should see "Shoes shop"
    And I should not see "Fruits shop"

  Scenario: see default facets when searching
    When I go to the search enterprises page
    And I fill in "query" with "shoes"
    And I press "Search"
    Then I should see "City" within "#facets-menu"

  Scenario: see category facets when searching
    When I go to the search enterprises page
    And I fill in "query" with "shoes"
    And I press "Search"
    Then I should see "Temáticas" within "#facets-menu"

  Scenario: see region on facets and results
    Given the following cities
      | name           | state |
      | Pres. Prudente | SP    |
    And the following enterprises
      | identifier | name          | city           |
      | art-pp     | Artesanato PP | Pres. Prudente |
    When I go to the search enterprises page
    And I fill in "query" with "Artesanato"
    And I press "Search"
    Then I should see "Pres. Prudente" within "#facet-menu-f_region"
    And I should see ", SP" within "#facet-menu-f_region"
    And I should see "Pres. Prudente, SP" within "#search-results"

  Scenario: find enterprise by region
    Given the following cities
      | name           | state |
      | Pres. Prudente | SP    |
    And the following enterprises
      | identifier | name          | city           |
      | art-pp     | Artesanato PP | Pres. Prudente |
    When I go to the search enterprises page
    And I fill in "query" with "Prudente"
    And I press "Search"
    Then I should see "Artesanato PP" within "#search-results"
 
  Scenario: find enterprise by category
    Given the following categories
      | name           |
	  | Software Livre |
    And the following enterprises
      | identifier | name     | category       |
      | noosfero   | Noosfero | software-livre |
    When I go to the search enterprises page
    And I fill in "query" with "software"
    And I press "Search"
    Then I should see "Noosfero" within "#search-results"

  Scenario: find enterprises without exact query
    Given the following enterprises
      | identifier | name                            |
      | noosfero   | Noosfero Developers Association |
    When I go to the search enterprises page
    And I fill in "query" with "Noosfero Association"
    And I press "Search"
    Then I should see "Noosfero Developers Association" within "#search-results"

  Scenario: filter enterprises by facet
    Given the following category
      | name           | parent    |
      | Software Livre | tematicas |
    And the following enterprises
      | identifier | name                | category       |
      | noosfero   | Noosfero Developers | software-livre |
      | facebook   | Facebook Developers |                |
    When I go to the search enterprises page
    And I fill in "query" with "Developers"
    And I press "Search"
    And I follow "Software Livre" within "#facets-menu"
    Then I should see "Noosfero Developers" within "#search-results"
    And I should not see "Facebook Developers"

  Scenario: remember facet filter when searching new query
    Given the following category
      | name           | parent    |
      | Software Livre | tematicas |
    And the following enterprises
      | identifier | name                | category       |
      | noosfero   | Noosfero Developers | software-livre |
      | rails-dev  | Rails Developers    |                |
      | rails-usr  | Rails Users         | software-livre |
    When I go to the search enterprises page
    And I fill in "query" with "Developers"
    And I press "Search"
    And I follow "Software Livre" within "#facets-menu"
    And I fill in "query" with "Rails"
    And I press "Search"
    Then I should see "Rails Users" within "#search-results"
    And I should not see "Rails Developers"
