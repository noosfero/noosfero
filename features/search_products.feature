Feature: search products
  As a noosfero user
  I want to search products
  In order to find ones that interest me

  Background:
    Given the search index is empty
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

  Scenario: show recent products on index
    When I go to the search products page
    Then I should see "wikis consultancy" within "#search-results"
    And I should see "social networks consultancy" within "#search-results"

  Scenario: not show pagination and facets on recent products
    When I go to the search products page
    Then The page should not contain "div.pagination"
    And The page should not contain "#facets-menu"

  Scenario: show empty search results
    When I search products for "something unrelated"
    Then I should see "None" within ".search-results-type-empty"

  Scenario: simple search for product
    Given there are no pending jobs
    When I search products for "wikis"
    Then I should see "wikis consultancy" within "#search-results"
    And I should see "wikis consultancy" within ".only-one-result-box"
    And I should see wikis consultancy's product image
    And I should not see "social networks consultancy"
    And I should not see social networks consultancy's product image

  Scenario: see default facets when searching
    When I go to the search products page
    And I fill in "search-input" with "wikis"
    And I press "Search"
    Then I should see "Related products" within "#facets-menu"
    Then I should see "City" within "#facets-menu"
    Then I should see "Qualifiers" within "#facets-menu"

  Scenario: show percentage (100%) of solidary economy inputs in results
    Given the following inputs
      | product           | category    | solidary |
      | wikis consultancy | development | true     |
    When I go to the search products page
    And I fill in "search-input" with "wikis"
    And I press "Search"
    Then I should see "100%" within "div.search-product-ecosol-percentage-icon-100"

  Scenario: show percentage (50%) of solidary economy inputs in results
    Given the following inputs
      | product           | category    | solidary |
      | wikis consultancy | development | true     |
      | wikis consultancy | development | false    |
    When I go to the search products page
    And I fill in "search-input" with "wikis"
    And I press "Search"
    Then I should see "50%" within "div.search-product-ecosol-percentage-icon-50"

  Scenario: show percentage (75%) of solidary economy inputs in results
    Given the following inputs
      | product           | category    | solidary |
      | wikis consultancy | development | true     |
      | wikis consultancy | development | true     |
      | wikis consultancy | development | true     |
      | wikis consultancy | development | false    |
    When I go to the search products page
    And I fill in "search-input" with "wikis"
    And I press "Search"
    Then I should see "75%" within "div.search-product-ecosol-percentage-icon-75"

  Scenario: show percentage (25%) of solidary economy inputs in results
    Given the following inputs
      | product           | category    | solidary |
      | wikis consultancy | development | true     |
      | wikis consultancy | development | false    |
      | wikis consultancy | development | false    |
      | wikis consultancy | development | false    |
    When I go to the search products page
    And I fill in "search-input" with "wikis"
    And I press "Search"
    Then I should see "25%" within "div.search-product-ecosol-percentage-icon-25"

  Scenario: display "zoom in" button on images on results
    Given the following products
      | owner       | category    | name     | price | img              |
      | colivre-ent | development | noosfero | 12.34 | noosfero-network |
    When I go to the search products page
    And I fill in "search-input" with "noosfero"
    And I press "Search"
    Then I should not see "No image"
    And I should see "Zoom in" within "a.zoomify-image"

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

  Scenario: don't search when products are disabled in environment
    Given feature "disable_asset_products" is enabled on environment
    When I go to the search products page
    Then I should see "There is no such page" within "#not-found"
