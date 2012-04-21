Feature: private profiles
  As a profile administrator
  I want to set it to private
  So that only members/friends can view its contents

  Background:
    Given the following community
      | identifier | name     | public_profile |
      | safernet   | Safernet | false          |
    And the following users
      | login   | public_profile |
      | joao    | true           |
      | shygirl | false          |

  Scenario: joining a private community
    Given I am logged in as "joao"
    When I go to Safernet's homepage
    Then I should see "members only"
    When I follow "Join"
    And "joao" is accepted on community "Safernet"
    Then "joao" should be a member of "Safernet"
    When I go to Safernet's homepage
    And I should not see "members only"

  Scenario: adding a friend with private profile
    Given I am logged in as "joao"
    When I go to shygirl's homepage
    Then I should see "friends only"
    And I follow "Add friend"
    When I go to shygirl's homepage
    Then I should not see "Add friend"

  Scenario: viewing a private community profile shouldn't show the news if not logged or not a member
    Given I am on Safernet's homepage
    Then I should not see "What's new"
    And I am logged in as "joao"
    When I am on Safernet's homepage
    Then I should not see "What's new"
    And "joao" is a member of "Safernet"
    When I am on Safernet's homepage
    Then I should see "What's new"

  Scenario: person private profiles should not display sensible information
    Given I am logged in as "joao"
    When I go to shygirl's homepage
    Then I should not see "Basic information"
    Then I should not see "Work"
    Then I should not see "Enterprises"
    Then I should not see "Network"

  Scenario: community private profiles should not display sensible information
    Given I am logged in as "joao"
    When I go to Safernet's homepage
    Then I should not see "Basic information"
