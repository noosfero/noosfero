Feature: HTTP caching

  As a sysdamin
  I want Noosfero to provide appropriate cache headers
  So that Varnish can serve content from the cache, everything works faster and everyone is happy

  Background:
    Given the following user
      | login | name |
      | joao | João Silva |

  Scenario: home page, default configuration
    When I go to the homepage
    Then the response should be valid for 5 minutes
    And the cache should be public

  Scenario: home page, custom configuration
    Given the following environment configuration
      | home_cache_in_minutes | 10 |
    When I go to the homepage
    Then the response should be valid for 10 minutes

  Scenario: search results, default configuration
    Given I am on the search page
    When I fill in "query" with "anything"
    And I press "Search"
    Then the response should be valid for 15 minutes

  Scenario: search results, custom configuration
    Given the following environment configuration
      | general_cache_in_minutes | 90 |
    When I go to the search page
    And I fill in "query" with "anything"
    And I press "Search"
    Then the response should be valid for 90 minutes

  Scenario: profile pages, default configuaration
    When I go to João Silva's homepage
    Then the response should be valid for 15 minutes

  Scenario: profile pages, custom configuration
    Given the following environment configuration
      | profile_cache_in_minutes | 90 |
    When I go to João Silva's homepage
    Then the response should be valid for 90 minutes

  Scenario: account controller should not be cached at all
    When I go to /account/login
    Then there must be no cache at all

  Scenario: profile administration
    Given I am logged in as "joao"
    When I go to João Silva's control panel
    Then there must be no cache at all

  Scenario: environment administration
    Given I am logged in as admin
    When I go to /admin
    Then there must be no cache at all

