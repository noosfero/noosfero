Feature: login
  As a user
  I want to login
  In order to view pages logged in

  Background:
    Given the following users
      | login | name |
      | joaosilva | Joao Silva |

  Scenario: login from portal homepage
    Given I am not logged in
    And I go to the homepage
    And I fill in the following:
      | Username | joaosilva |
      | Password | 123456 |
    When I press "Log in"
    Then I should be on the homepage

  Scenario: login from some profile page
    Given I am not logged in
    And the following users
      | login | name |
      | mariasilva | Maria Silva |
    And I go to Maria Silva's homepage
    And I follow "Login"
    And I fill in the following:
      | Username | joaosilva |
      | Password | 123456 |
    When I press "Log in"
    Then I should be on Maria Silva's homepage

  Scenario: view my control panel
    Given I am not logged in
    And I go to Joao Silva's control panel
    And I should be on login page
    And I fill in the following:
      | Username | joaosilva |
      | Password | 123456 |
    When I press "Log in"
    Then I should be on Joao Silva's control panel
