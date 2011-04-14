Feature: balloon
  I want to view a balloon when mouse clicks on profile trigger

  Background:
    Given the following users
      | login     | name       |
      | joaosilva | Joao Silva |
    And the following communities
      | identifier | name      |
      | sample     | Sample    |

  @selenium
  Scenario: I should not see trigger if not enabled
    Given feature "show_balloon_with_profile_links_when_clicked" is disabled on environment
    When I go to /browse/people
    Then I should not see "Profile links"

  @selenium
  Scenario: I should not see trigger by default
    Given the following blocks
      | owner       | type        |
      | environment | PeopleBlock |
    And feature "show_balloon_with_profile_links_when_clicked" is enabled on environment
    When I go to the homepage
    Then I should not see "Friends"

  @selenium
  Scenario: I should see balloon when clicked on people block trigger
    Given the following blocks
      | owner       | type        |
      | environment | PeopleBlock |
    And feature "show_balloon_with_profile_links_when_clicked" is enabled on environment
    When I go to the homepage
    And I follow "Profile links"
    Then I should see "Friends"

  @selenium
  Scenario: I should see balloon when clicked on community block trigger
    Given feature "show_balloon_with_profile_links_when_clicked" is enabled on environment
    When I go to /browse/communities
    And I follow "Profile links"
    Then I should see "Members"

  @selenium
  Scenario: I should not see trigger if not enabled on page
    Given feature "show_balloon_with_profile_links_when_clicked" is disabled on environment
    When I go to /assets/people
    Then I should not see "Profile links"

  @selenium
  Scenario: I should not see trigger by default on page
    Given feature "show_balloon_with_profile_links_when_clicked" is enabled on environment
    When I go to /assets/communities
    Then I should not see "Members"

  @selenium
  Scenario: I should see balloon when clicked on page trigger
    Given feature "show_balloon_with_profile_links_when_clicked" is enabled on environment
    When I go to /assets/communities
    And I follow "Profile links"
    Then I should see "Members"
    And I should see "Agenda"
