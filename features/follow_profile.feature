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

  @selenium
  Scenario: Common noofero user follow a community
    Given I am logged in as "johnsnow"
    When I go to nightswatch's homepage
    When I follow "Follow"
    When I check "Work"
    When I press "Follow"
    And I wait 1 second
    Then "johnsnow" should be a follower of "nightswatch" in circle "Work"

  @selenium
  Scenario: Common noofero user follow a community in more than one circle
    Given I am logged in as "johnsnow"
    When I go to nightswatch's homepage
    When I follow "Follow"
    When I check "Work"
    When I check "Favorites"
    When I press "Follow"
    And I wait 1 second
    Then "johnsnow" should be a follower of "nightswatch" in circle "Work"
    And "johnsnow" should be a follower of "nightswatch" in circle "Favorites"

  @selenium
  Scenario: No see another profile type circle when following a community
    Given I am logged in as "johnsnow"
    When I go to nightswatch's homepage
    When I follow "Follow"
    Then I should not see "Family"
    And I should see "Favorites"
    And I should see "Work"

  @selenium
  Scenario: Common noofero user follow a community then cancel the action
    Given I am logged in as "johnsnow"
    When I go to nightswatch's homepage
    When I follow "Follow"
    When I press "Cancel"
    And I wait 1 second
    Then I should not see "Family"
    And I should not see "Favorites"
    And I should not see "Work"
    And I should not see "New Circle"
    Then "johnsnow" should not be a follower of "nightswatch"

  @selenium
  Scenario: Common noofero user cancel the circle creation action
    Given I am logged in as "johnsnow"
    When I go to nightswatch's homepage
    When I follow "Follow"
    When I follow "New Circle"
    When I press "Cancel"
    And I wait 1 second
    Then I should not see "Circle name"
    And I should not see "Create"

  @selenium
  Scenario: Noosfero user see new circle option when following a community
    Given I am logged in as "johnsnow"
    When I go to nightswatch's homepage
    When I follow "Follow"
    Then I should see "New Circle"

  @selenium
  Scenario: Common noofero user follow a community with a new circle
    Given I am logged in as "johnsnow"
    When I go to nightswatch's homepage
    When I follow "Follow"
    When I follow "New Circle"
    And I fill in "text-field-name-new-circle" with "Winterfell"
    When I follow "Create"
    When I check "Winterfell"
    When I press "Follow"
    And I wait 1 second
    Then "johnsnow" should be a follower of "nightswatch" in circle "Winterfell"

  @selenium
  Scenario: Common noofero user create a new circle when following a community
    Given I am logged in as "johnsnow"
    When I go to nightswatch's homepage
    When I follow "Follow"
    When I follow "New Circle"
    And I fill in "text-field-name-new-circle" with "Winterfell"
    When I follow "Create"
    And I wait 1 second
    Then "johnsnow" should have the circle "Winterfell" with profile type "Community"
    Then I should not see "Circle name"
    Then I should not see "Create"

  @selenium
  Scenario: Common noofero user unfollow a community
    Given "johnsnow" is a follower of "nightswatch" in circle "Work"
    And I am logged in as "johnsnow"
    When I go to nightswatch's homepage
    When I follow "Unfollow"
    Then "johnsnow" should not be a follower of "nightswatch"

