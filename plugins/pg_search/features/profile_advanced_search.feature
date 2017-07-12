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
    And I follow "Edit sideboxes"
    And I move the cursor over ".profile-search-block"
    And I follow "Edit" within ".profile-search-block"
    And I check "Enable advanced search"
    And I press "Save"

  @selenium
  Scenario: filters should be hidden by default in the profile page
    When I go to /joaosilva
    Then The page should contain only 0 ".profile-search-block #facets-wrapper"

  @selenium
  Scenario:
    When I go to /joaosilva
    And I click "#facets-toggle"
    Then The page should contain only 1 ".profile-search-block #facets-wrapper"

  @selenium
  Scenario: filters should be collapsed by default in the profile search page
    When I go to /profile/joaosilva/search
    Then The page should contain only 1 ".profile-search-block #facets-wrapper"
