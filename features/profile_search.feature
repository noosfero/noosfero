Feature: search inside a profile
  As a noosfero user
  I want to search
  In order to find stuff from a profile

  Background:
    Given the following users
      | login     | name       |
      | joaosilva | Joao Silva |
    And the following articles
      | owner     | name                 | body |
      | joaosilva | bees and butterflies | this is an article about bees and butterflies |
      | joaosilva | whales and dolphins  | this is an article about whales and dolphins  |

  Scenario: search on profile
    Given I go to joaosilva's profile
    And I fill in "q" with "bees"
    And I press "Search"
    Then I should see "bees and butterflies" within ".main-block"
    And I should not see "whales and dolphins" within ".main-block"

  Scenario: search for event on profile
    Given the following events
      | owner     | name                | start_date |
      | joaosilva | Group meeting       | 2009-10-01 |
      | joaosilva | John Doe's birthday | 2009-09-01 |
    When I go to joaosilva's profile
    And I fill in "q" with "birthday"
    And I press "Search"
    Then I should see "John Doe's birthday" within ".main-block"
    And I should not see "Group meeting" within ".main-block"

  Scenario: simple search for event on profile search block
    Given the following blocks
      | owner     | type                |
      | joaosilva | ProfileSearchBlock  |
    When I go to joaosilva's profile
    And I fill in "q" with "bees" within ".profile-search-block"
    And I press "Search" within ".profile-search-block"
    Then I should see "bees and butterflies" within ".main-block"

  Scenario: not display unpublished articles
    Given the following articles
      | owner     | name                | body                      | published |
      | joaosilva | published article   | this is a public article  | true      |
      | joaosilva | unpublished article | this is a private article | false     |
    And I go to joaosilva's profile
    And I fill in "q" with "article"
    And I press "Search"
    Then I should see "public article" within ".main-block"
    And I should not see "private article" within ".main-block"

  Scenario: search on environment
    Given I go to joaosilva's profile
    And I fill in "q" with "bees"
    And I choose "General"
    And I press "Search"
    Then I should be on the search page
    And I should see "bees and butterflies" within "#search-page"

  Scenario: not display search on private profiles
    Given the following users
      | login      | name        | public_profile |
      | mariasilva | Maria Silva | false          |
    And I go to /profile/mariasilva/search
    Then I should see "friends only"
