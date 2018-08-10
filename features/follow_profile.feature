Feature: follow profile
  As a noosfero user
  I want to follow a profile
  So I can receive notifications from it

  Background:
    Given the following community
      | identifier  | name          |
      | nightswatch | Nights Watch  |
    And the following users
      | login    |
      | johnsnow |
    And the user "johnsnow" has the following circles
      | name      | profile_type |
      | Family    | Person       |
      | Work      | Community    |
      | Favorites | Community    |

  @selenium-fixme
  Scenario: Common noosfero user follow a community
    Given I am logged in as "johnsnow"
    When I go to nightswatch's homepage
    And I follow "Follow"
    And I check "Work"
    And I follow "Follow"
    Then I should see "You are now following Nights Watch"

  @selenium
  Scenario: No see another profile type circle when following a community
    Given I am logged in as "johnsnow"
    When I go to nightswatch's homepage
    When I follow "Follow"
    Then I should not see "Family"
    And I should see "Favorites"
    And I should see "Work"

  @selenium
  Scenario: Common noosfero user follow a community then cancel the action
    Given I am logged in as "johnsnow"
    When I go to nightswatch's homepage
    When I follow "Follow"
    When I follow "Cancel"
    Then I should not see "Family"
    And I should not see "Favorites"
    And I should not see "Work"
    And I should not see "New Circle"
    Then "johnsnow" should not be a follower of "nightswatch"

  @selenium
  Scenario: Common noosfero user cancel the circle creation action
    Given I am logged in as "johnsnow"
    When I go to nightswatch's homepage
    When I follow "Follow"
    When I follow "New Circle"
    When I follow "Cancel"
    And I wait for 1 second
    Then I should not see "Circle name"
    And I should not see "Create"

  @selenium
  Scenario: Noosfero user see new circle option when following a community
    Given I am logged in as "johnsnow"
    When I go to nightswatch's homepage
    When I follow "Follow"
    Then I should see "New Circle"

  @selenium
  Scenario: Common noosfero user create a new circle when following a community
    Given I am logged in as "johnsnow"
    When I go to nightswatch's homepage
    When I follow "Follow"
    When I follow "New Circle"
    And I fill in "text-field-name-new-circle" with "Winterfell"
    When I follow "Create"
    Then I should see "Winterfell"
