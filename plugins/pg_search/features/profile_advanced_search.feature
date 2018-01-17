Feature: profile advanced search
  As a noosfero user
  I want the profile search to be advanced
  In order to apply filters when searching in profiles

  Background:
    Given plugin PgSearch is enabled on environment
    And the following users
      | login     | name       |
      | joaosilva | Joao Silva |
    And the following articles
      | owner     | name              | body |
      | joaosilva | Save the whales   | ...  |
    And the following blocks
      | owner            | type               |
      | joaosilva        | ProfileSearchBlock |
    And I am logged in as "joaosilva"
    And I go to joaosilva's control panel

  @selenium
  Scenario: filters should be hidden by default in the profile page
    Given I follow "Edit sideboxes"
    And I move the cursor over ".profile-search-block"
    And I follow "Edit" within ".profile-search-block"
    And I check "Enable advanced search"
    And I press "Save"
    When I go to /joaosilva
    Then The page should not contain ".profile-search-block .facet"

  @selenium
  Scenario: filters should be collapsed by default in the profile search page
    Given I follow "Edit sideboxes"
    And I move the cursor over ".profile-search-block"
    And I follow "Edit" within ".profile-search-block"
    And I check "Enable advanced search"
    And I press "Save"
    When I go to /profile/joaosilva/search
    Then The page should contain ".profile-search-block .facet"
