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
    And I press "Yes, I want to join"
    And "joao" is accepted on community "Safernet"
    Then "joao" should be a member of "Safernet"
    When I go to Safernet's homepage
    And I should not see "members only"

  Scenario: adding a friend with private profile
    Given I am logged in as "joao"
    When I go to shygirl's homepage
    Then I should see "friends only"
    When I follow "Add friend"
    And I press "Yes, I want"
