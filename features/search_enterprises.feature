Feature: search enterprises
  As a noosfero user
  I want to search enterprises
  In order to find ones that interest me

  Background:
    Given the search index is empty
    And the following enterprises
      | identifier | name        | img |
      | shop1      | Shoes shop  | shoes |
      | shop2      | Fruits shop | fruits |
    And the following categories as facets
      | name      |
      | Temáticas |

  Scenario: show recent enterprises on index
    Given there are no pending jobs
    When I go to the search enterprises page
    Then I should see "Shoes shop" within "#search-results"
    And I should see Shoes shop's profile image
    And I should see "Fruits shop" within "#search-results"
    And I should see Fruits shop's profile image

  Scenario: show empty search results
    When I search enterprises for "something unrelated"
    Then I should see "None" within ".search-results-type-empty"

  Scenario: simple search for enterprise
    When I go to the search enterprises page
    And I fill in "search-input" with "shoes"
    And I press "Search"
    Then I should see "Shoes shop" within ".only-one-result-box"
    And I should see Shoes shop's profile image
    And I should not see "Fruits shop"
    And I should not see Fruits shop's profile image

  Scenario: link to enterprise homepage on search results
    Given I search enterprises for "shoes"
    When I follow "Shoes shop"
    Then I should be on shop1's profile

  Scenario: show clean enterprise homepage on search results
    Given the following articles
      | owner | name | body | homepage |
      | shop1 | Shoes home | This is the <i>homepage</i> of Shoes shop! It has a very long and pretty vague description, just so we can test wether the system will correctly create an excerpt of this text. We should probably talk about shoes. | true |
    When I search enterprises for "shoes"
    Then I should see "This is the homepage of" within ".search-enterprise-description"
    And I should see "about sho..." within ".search-enterprise-description"

  Scenario: show clean enterprise description on search results
    Given the following enterprises
      | identifier | name | description |
      | shop3 | Clothes shop | This <b>clothes</b> shop also sells shoes! This too has a very long and pretty vague description, just so we can test wether the system will correctly create an excerpt of this text. Clothes are a really important part of our lives. |
    When I search enterprises for "clothes"
    And I should see "This clothes shop" within ".search-enterprise-description"
    And I should see "really import..." within ".search-enterprise-description"

  Scenario: see default facets when searching
    When I go to the search enterprises page
    And I fill in "search-input" with "shoes"
    And I press "Search"
    Then I should see "City" within "#facets-menu"

  Scenario: see category facets when searching
    When I go to the search enterprises page
    And I fill in "search-input" with "shoes"
    And I press "Search"
    Then I should see "Temáticas" within "#facets-menu"

  Scenario: see region on facets and results
    Given the following cities
      | name           | state |
      | Pres. Prudente | SP    |
    And the following enterprises
      | identifier | name          | region           |
      | art-pp     | Artesanato PP | Pres. Prudente |
    When I go to the search enterprises page
    And I fill in "search-input" with "Artesanato"
    And I press "Search"
    Then I should see "Pres. Prudente" within "#facet-menu-f_region"
    And I should see ", SP" within "#facet-menu-f_region"
    And I should see "City" within ".search-enterprise-region-label"
    And I should see "Pres. Prudente, SP" within ".search-enterprise-region-name"

  Scenario: find enterprise by region
    Given the following cities
      | name           | state |
      | Pres. Prudente | SP    |
    And the following enterprises
      | identifier | name          | region         |
      | art-pp     | Artesanato PP | Pres. Prudente |
    When I go to the search enterprises page
    And I fill in "search-input" with "Prudente"
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
    And I fill in "search-input" with "software"
    And I press "Search"
    Then I should see "Noosfero" within "#search-results"
    And I should see "Software Livre" within ".search-enterprise-category"

  Scenario: show category hierarchy on search results
    Given the following categories
      | name           | parent |
      | Software Livre |        |
      | Rails          | software-livre |
    And the following enterprises
      | identifier | name     | category       |
      | noosfero   | Noosfero | rails |
    When I search enterprises for "Rails"
    Then I should see "Software Livre" within ".search-enterprise-category"
    And I should see "Rails" within ".search-enterprise-category"

  Scenario: find enterprises without exact query
    Given the following enterprises
      | identifier | name                            |
      | noosfero   | Noosfero Developers Association |
    When I go to the search enterprises page
    And I fill in "search-input" with "Noosfero Association"
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
    And I fill in "search-input" with "Developers"
    And I press "Search"
    And I follow "Software Livre" within "#facets-menu"
    Then I should see "Noosfero Developers" within "#search-results"
    And I should not see "Facebook Developers"
    # facet should also be de-selectable
    When I follow "remove facet" within ".facet-selected"
    Then I should see "Facebook Developers"

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
    And I fill in "search-input" with "Developers"
    And I press "Search"
    And I follow "Software Livre" within "#facets-menu"
    And I fill in "search-input" with "Rails"
    And I press "Search"
    Then I should see "Rails Users" within "#search-results"
    And I should not see "Rails Developers"
