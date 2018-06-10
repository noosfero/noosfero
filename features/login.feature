Feature: login
  As a user
  I want to login
  In order to view pages logged in

  Background:
    Given the following users
      | login | name |
      | joaosilva | Joao Silva |

  @selenium
  Scenario: login from portal homepage
    Given feature "allow_change_of_redirection_after_login" is disabled on environment
    And I am not logged in
    And I go to the homepage
    And I follow "Login"
    And I wait 0.5 second for popin animation
    And I fill in the following:
      | Username / Email | joaosilva |
      | Password | 123456 |
    When I follow "Log in"
    Then I should be on the homepage
    And I should be logged in as "joaosilva"

  @selenium
  Scenario: login from some profile page
    Given feature "allow_change_of_redirection_after_login" is disabled on environment
    And I am not logged in
    And the following users
      | login | name |
      | mariasilva | Maria Silva |
    And the following articles
      | owner      | name         | homepage |
      | mariasilva | my home page | true |
    And I go to mariasilva's homepage
    And I follow "Login"
    And I wait 0.5 second for popin animation
    And I fill in the following:
      | Username / Email | joaosilva |
      | Password | 123456 |
    When I follow "Log in"
    Then I should be on mariasilva's homepage

  Scenario: view my control panel
    Given feature "allow_change_of_redirection_after_login" is disabled on environment
    And I am not logged in
    And I go to joaosilva's control panel
    And I should be on login page
    And I fill in the following:
      | Username / Email | joaosilva |
      | Password | 123456 |
    When I follow "Log in"
    Then I should be on joaosilva's control panel

  Scenario: be redirected if user goes to login page and is logged
    Given I am logged in as "joaosilva"
    And I go to login page
    Then I should be on joaosilva's control panel
