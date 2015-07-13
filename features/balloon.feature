Feature: balloon
  I want to view a balloon when mouse clicks on profile trigger

  Background:
    Given the following users
      | login     | name       |
      | joaosilva | Joao Silva |
    And the following communities
      | identifier | name      |
      | sample     | Sample    |
    And I am logged in as "joaosilva"

  @selenium
  Scenario: I should not see trigger if not enabled
    Given feature "show_balloon_with_profile_links_when_clicked" is disabled on environment
    When I go to /search/people
    Then I should not see "Profile links"

  @selenium
  Scenario: I should not see trigger by default
    Given feature "show_balloon_with_profile_links_when_clicked" is enabled on environment
    When I go to /search/people
    Then I should not see "Friends"

  @selenium
  Scenario: I should see balloon when clicked on people block trigger
    Given feature "show_balloon_with_profile_links_when_clicked" is enabled on environment
    And I go to /search/people
    And display ".person-trigger"
    When I follow "Profile links"
    Then I should see "Friends"

  @selenium
  Scenario: I should see balloon when clicked on community block trigger
    Given feature "show_balloon_with_profile_links_when_clicked" is enabled on environment
    And I go to /search/communities
    And display ".community-trigger"
    When I follow "Profile links"
    Then I should see "Members"

  @selenium
  Scenario: I should not see trigger if not enabled on page
    Given feature "show_balloon_with_profile_links_when_clicked" is disabled on environment
    When I go to /search/people
    Then I should not see "Profile links"

  @selenium
  Scenario: I should not see trigger by default on page
    Given feature "show_balloon_with_profile_links_when_clicked" is enabled on environment
    When I go to /search/communities
    Then I should not see "Members"

  @selenium
  Scenario: I should see balloon when clicked on page trigger
    Given feature "show_balloon_with_profile_links_when_clicked" is enabled on environment
    And I go to /search/communities
    And display ".community-trigger"
    When I follow "Profile links"
    Then I should see "Members"
    And I should see "Agenda"
