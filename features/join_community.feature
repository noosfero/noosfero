Feature: join a community
  As a user
  I want to join a community
  In order to interact with other people

  Background:
    Given the following users
      | login | name |
      | joaosilva | Joao Silva |
    Given the following communities
      | identifier | name |
      | sample-community | Sample Community |

  Scenario: a logged user asks to join a community with "join_community_popup"
    Given feature "join_community_popup" is enabled on environment
    And I am logged in as "joaosilva"
    And I go to Sample Community's homepage
    And I press "Yes"
    Then I should be on Sample Community's homepage
    And "Joao Silva" should be a member of "Sample Community"

  Scenario: a logged user asks to join a community without "join_community_popup"
    Given feature "join_community_popup" is disabled on environment
    And I am logged in as "joaosilva"
    And I am on Sample Community's homepage
    And I follow "Join"
    And I should see "Are you sure you want to join Sample Community?"
    When I press "Yes, I want to join."
    Then "Joao Silva" should be a member of "Sample Community"

  Scenario: a not logged user asks join a community
    Given feature "join_community_popup" is enabled on environment
    And I am not logged in
    And I go to Sample Community's homepage
    And I press "Yes"
    And I fill in the following:
      | Username | joaosilva |
      | Password | 123456 |
    And I press "Log in"
    And I should see "Are you sure you want to join Sample Community?"
    When I press "Yes, I want to join"
    Then I should be on Sample Community's homepage
    And "Joao Silva" should be a member of "Sample Community"

  Scenario: a non-user ask to join a community
    Given feature "join_community_popup" is enabled on environment
    And I am not logged in
    And I go to Sample Community's homepage
    And I press "Yes"
    And I follow "I want to participate"
    And I fill in the following:
      | e-mail | jose@domain.br |
      | Username | joseoliveira |
      | Password | 123456 |
      | Password confirmation | 123456 |
      | Name | Jose Oliveira |
   And I press "Sign up"
   And I should see "Are you sure you want to join Sample Community?"
   When I press "Yes, I want to join"
   Then I should be on Sample Community's homepage
   And "Jose Oliveira" should be a member of "Sample Community"

  Scenario: ask confirmation before join community
    Given I am on the homepage
    And the following communities
      | name |
      | Community to join |
    And I am logged in as "joaosilva"
    When I am on /profile/community-to-join/join
    Then I should see "Are you sure you want to join Community to join"

  Scenario: dont ask confirmation before join community if already member
    Given I am on the homepage
    And the following communities
      | name |
      | Community to join |
    And joaosilva is member of community-to-join
    And I am logged in as "joaosilva"
    When I am on /profile/community-to-join/join
    Then I should not see "Are you sure you want to join Community to join"
