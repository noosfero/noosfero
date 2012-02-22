Feature: search contents
  As a noosfero user
  I want to search contents
  In order to find ones that interest me 

  Background:
    Given the search index is empty
    And the following users
      | login     | name       |
      | joaosilva | Joao Silva |
    And the following articles
      | owner     | name                 | body                                          | 
      | joaosilva | bees and butterflies | this is an article about bees and butterflies |
      | joaosilva | whales and dolphins  | this is an article about whales and dolphins  |

  Scenario: show recent contents on index (empty query)
    When I go to the search contents page
    Then I should see "bees and butterflies" within "#search-results"
    And I should see "whales and dolphins" within "#search-results"

  Scenario: simple search for content
    When I go to the search contents page
    And I fill in "query" with "whales"
    And I press "Search"
    Then I should see "whales and dolphins" within "#search-results"
    And I should not see "bees and butterflies"

  Scenario: search contents by category
    Given the following category
      | name           |
	  | Software Livre |
    And the following articles
      | owner     | name           | body                    | category       |
      | joaosilva | using noosfero | noosfero is a great CMS | software-livre |
    When I go to the search articles page
    And I fill in "query" with "software livre"
    And I press "Search"
    Then I should see "using noosfero" within "#search-results"
    And I should not see "bees and butterflies"
    And I should not see "whales and dolphins"

  Scenario: see default facets when searching
    When I go to the search articles page
    And I fill in "query" with "bees"
    And I press "Search"
    Then I should see "Type" within "#facets-menu"
    Then I should see "Published date" within "#facets-menu"
    Then I should see "Profile" within "#facets-menu"
    Then I should see "Categories" within "#facets-menu"

  Scenario: find enterprises without exact query
    When I go to the search articles page
    And I fill in "query" with "article bees"
    And I press "Search"
    Then I should see "bees and butterflies" within "#search-results"

  Scenario: filter contents by facet
    Given the following categories as facets
      | name      | 
      | Temáticas |
    And the following categories
      | name           | parent    |
      | Software Livre | tematicas |
      | Big Brother    | tematicas |
    And the following articles
      | owner | name | body | category |
      | joaosilva | noosfero and debian | this is an article about noosfero and debian | software-livre |
      | joaosilva | facebook and 1984 | this is an article about facebook and 1984 | big-brother |
    When I go to the search articles page
    And I fill in "query" with "this is an article"
    And I press "Search"
    And I follow "Software Livre" within "#facets-menu"
    Then I should see "noosfero and debian" within "#search-results"
    And I should not see "facebook and 1984"

  Scenario: remember facet filter when searching new query
    Given the following categories as facets
      | name      | 
      | Temáticas |
    And the following category
      | name           | parent    |
      | Software Livre | tematicas |
    And the following articles
      | owner | name | body | category |
      | joaosilva | noosfero and debian | this is an article about noosfero and debian | software-livre |
      | joaosilva | facebook and 1984 | this is an article about facebook and 1984 | big-brother |
      | joaosilva | facebook defense | facebook is not so bad | software-livre |
    When I go to the search articles page
    And I fill in "query" with "this is an article"
    And I press "Search"
    And I follow "Software Livre" within "#facets-menu"
    And I fill in "query" with "facebook"
    And I press "Search"
    Then I should see "facebook defense" within "#search-results"
    And I should not see "1984"
