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

  Scenario: ask confirmation before join community
    Given I am logged in as "joaosilva"
    And I am on Sample Community's homepage
    When I follow "Join"
    Then I should see "Are you sure you want to join Sample Community"

  Scenario: dont ask confirmation before join community if already member
    Given joaosilva is member of sample-community
    And I am logged in as "joaosilva"
    When I go to /profile/sample-community
    Then I should not see "Are you sure you want to join Community to join"
