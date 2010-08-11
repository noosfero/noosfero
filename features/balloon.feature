Feature: balloon
  I want to view a balloon when mouse clicks on profile trigger

  Background:
    Given I am on the homepage
    Given the following users
      | login | name |
      | joaosilva | Joao Silva |
    And the following communities
      | identifier | name    |
      | sample     | Sample  |

  @selenium
  Scenario: I should not see trigger if not enabled
    Given the following blocks
      | owner       | type        |
      | environment | PeopleBlock |
    And feature "show_balloon_with_profile_links_when_clicked" is disabled on environment
    And I go to the homepage
    Then I should not see "Friends"

  @selenium
  Scenario: I should not see trigger by default
    Given the following blocks
      | owner       | type        |
      | environment | PeopleBlock |
    And feature "show_balloon_with_profile_links_when_clicked" is enabled on environment
    And I go to the homepage
    Then I should not see "Friends"

  @selenium
  Scenario: I should see balloon when clicked on people block trigger
    Given the following blocks
      | owner       | type        |
      | environment | PeopleBlock |
    And feature "show_balloon_with_profile_links_when_clicked" is enabled on environment
    And I go to the homepage
    When I click ".menu-submenu-trigger"
    Then I should see "Profile"
    And I should see "Friends"
    And I should see "Home Page"

  @selenium
  Scenario: I should see balloon when clicked on community block trigger
    Given the following blocks
      | owner       | type        |
      | environment | CommunitiesBlock |
    And feature "show_balloon_with_profile_links_when_clicked" is enabled on environment
    And I go to the homepage
    When I click ".menu-submenu-trigger"
    Then I should see "Profile"
    And I should see "Members"
    And I should see "Agenda"

  @selenium
  Scenario: I should not see trigger if not enabled on page
    Given feature "show_balloon_with_profile_links_when_clicked" is disabled on environment
    And I go to /assets/communities
    Then I should not see "Members"

  @selenium
  Scenario: I should not see trigger by default on page
    Given feature "show_balloon_with_profile_links_when_clicked" is enabled on environment
    And I go to /assets/communities
    Then I should not see "Members"

  @selenium
  Scenario: I should see balloon when clicked on page trigger
    Given feature "show_balloon_with_profile_links_when_clicked" is enabled on environment
    And I go to /assets/communities
    When I click ".menu-submenu-trigger"
    Then I should see "Members"
    And I should see "Agenda"
    And I should see "Home Page"
