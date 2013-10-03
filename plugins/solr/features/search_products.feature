Feature: search products
  As a noosfero user
  I want to search products
  In order to find ones that interest me

  Background:
    Given the search index is empty
    And plugin Solr is enabled on environment
    And feature "disable_asset_products" is disabled on environment
    And the following enterprises
      | identifier  | name    |
      | colivre-ent | Colivre |
    And the following product_categories
      | name        |
      | Development |
    And the following products
      | owner       | category    | name                        | price | img    |
      | colivre-ent | development | social networks consultancy | 1.00  | fruits |
      | colivre-ent | development | wikis consultancy           | 2.00  | shoes  |

  Scenario: not show pagination and facets on recent products
    When I go to the search products page
    Then The page should not contain "div.pagination"
    And The page should not contain "#facets-menu"

  Scenario: see default facets when searching
    When I go to the search products page
    And I fill in "search-input" with "wikis"
    And I press "Search"
    Then I should see "Related products" within "#facets-menu"
    Then I should see "City" within "#facets-menu"
    Then I should see "Qualifiers" within "#facets-menu"

  Scenario: search products by category
    Given the following product_category
      | name           |
      | Software Livre |
    And the following product
      | owner       | name     | category       |
      | colivre-ent | Noosfero | software-livre |
    When I go to the search products page
    And I fill in "search-input" with "software livre"
    And I press "Search"
    Then I should see "Noosfero" within "#search-results"
    And I should not see "wikis consultancy"
    And I should not see "social networks consultancy"

  Scenario: see region on facets and results
    Given the following cities
      | name           | state |
      | Pres. Prudente | SP    |
    And the following enterprise
      | identifier | name          | region         |
      | art-pp     | Artesanato PP | Pres. Prudente |
    And the following product_category
      | name      |
      | Solidária |
    And the following product
      | owner  | name            | category  |
      | art-pp | Arte em Madeira | solidaria |
    When I go to the search products page
    And I fill in "search-input" with "Madeira"
    And I press "Search"
    Then I should see "Pres. Prudente" within "#facet-menu-f_region"
    And I should see ", SP" within "#facet-menu-f_region"
    And I should see "Pres. Prudente, SP" within "#search-results"

  Scenario: find product by region
    Given the following cities
      | name           | state |
      | Pres. Prudente | SP    |
    And the following enterprise
      | identifier | name          | region         |
      | art-pp     | Artesanato PP | Pres. Prudente |
    And the following product_category
      | name      |
      | Solidária |
    And the following product
      | owner  | name            | category  |
      | art-pp | Arte em Madeira | solidaria |
    When I go to the search products page
    And I fill in "search-input" with "Prudente"
    And I press "Search"
    Then I should see "Arte em Madeira" within "#search-results"

  Scenario: find products without exact query
    Given the following product_category
      | name           |
      | Software Livre |
    And the following products
      | owner       | name                             | category       |
      | colivre-ent | Noosfero Social Network Platform | software-livre |
    When I go to the search products page
    And I fill in "search-input" with "Noosfero Network"
    And I press "Search"
    Then I should see "Noosfero Social Network Platform" within "#search-results"

  Scenario: filter products by facet
    Given the following enterprises
      | identifier | name    |
      | fb         | FB inc. |
    And the following categories as facets
      | name      |
      | Temáticas |
    And the following product_categories
      | name           | parent    |
      | Software Livre | tematicas |
      | Big Brother    | tematicas |
    And the following products
      | owner       | name             | category       |
      | colivre-ent | Noosfero Network | software-livre |
      | fb          | Facebook Network | big-brother    |
    When I go to the search products page
    And I fill in "search-input" with "Network"
    And I press "Search"
    And I follow "Software Livre" within "#facets-menu"
    Then I should see "Noosfero Network" within "#search-results"
    And I should not see "Facebook Network"
    # facet should also be de-selectable
    When I follow "remove facet" within ".facet-selected"
    Then I should see "Facebook Network"

  Scenario: remember facet filter when searching new query
    Given the following enterprises
      | identifier | name    |
      | fb         | FB inc. |
      | other      | Other   |
    And the following categories as facets
      | name      |
      | Temáticas |
    And the following product_categories
      | name           | parent    |
      | Software Livre | tematicas |
      | Big Brother    | tematicas |
      | Other          | tematicas |
    And the following products
      | owner       | name               | category       |
      | colivre-ent | Noosfero Network   | software-livre |
      | fb          | Facebook Network   | big-brother    |
      | other       | Other open         | software-livre |
      | other       | Other closed       | big-brother    |
    When I go to the search products page
    And I fill in "search-input" with "Network"
    And I press "Search"
    And I follow "Software Livre" within "#facets-menu"
    And I fill in "search-input" with "Other"
    And I press "Search"
    Then I should see "Other open" within "#search-results"
    And I should not see "Other closed"

