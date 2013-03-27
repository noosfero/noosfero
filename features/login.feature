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
    And I fill in the following:
      | Username / Email | joaosilva |
      | Password | 123456 |
    When I press "Log in"
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
    And I fill in the following:
      | Username / Email | joaosilva |
      | Password | 123456 |
    When I press "Log in"
    Then I should be on mariasilva's homepage

  Scenario: view my control panel
    Given feature "allow_change_of_redirection_after_login" is disabled on environment
    And I am not logged in
    And I go to joaosilva's control panel
    And I should be on login page
    And I fill in the following:
      | Username / Email | joaosilva |
      | Password | 123456 |
    When I press "Log in"
    Then I should be on joaosilva's control panel

  Scenario: be redirected if user goes to login page and is logged
    Given I am logged in as "joaosilva"
    And I go to login page
    Then I should be on joaosilva's control panel

  @selenium
  Scenario: stay on the same page after login if this is the environment default
    Given feature "allow_change_of_redirection_after_login" is enabled on environment
    And I am not logged in
    And the environment is configured to stay on the same page after login
    And the following users
      | login | name |
      | mariasilva | Maria Silva |
    And the following articles
      | owner      | name         | homepage |
      | mariasilva | my home page | true |
    And I go to mariasilva's homepage
    And I follow "Login"
    And I fill in the following:
      | Username / Email | joaosilva |
      | Password | 123456 |
    When I press "Log in"
    Then I should be on mariasilva's homepage

  @selenium
  Scenario: go to site homepage if this is the environment default
    Given feature "allow_change_of_redirection_after_login" is enabled on environment
    And I am not logged in
    And the environment is configured to redirect to site homepage after login
    And I go to joaosilva's homepage
    And I follow "Login"
    And I fill in the following:
      | Username / Email | joaosilva |
      | Password | 123456 |
    When I press "Log in"
    Then I should be on the homepage

  @selenium
  Scenario: go to user profile after login if this is the environment default
    Given feature "allow_change_of_redirection_after_login" is enabled on environment
    And I am not logged in
    And the environment is configured to redirect to user profile page after login
    And I go to the homepage
    And I follow "Login"
    And I fill in the following:
      | Username / Email | joaosilva |
      | Password | 123456 |
    When I press "Log in"
    Then I should be on joaosilva's profile

  @selenium
  Scenario: go to profile homepage after login if this is the environment default
    Given the following articles
      | owner     | name           | body               | homepage |
      | joaosilva | Sample Article | This is an article | true     |
    And feature "allow_change_of_redirection_after_login" is enabled on environment
    And I am not logged in
    And the environment is configured to redirect to profile homepage after login
    And I go to the homepage
    And I follow "Login"
    And I fill in the following:
      | Username / Email | joaosilva |
      | Password | 123456 |
    When I press "Log in"
    Then I should be on joaosilva's homepage

  @selenium
  Scenario: go to profile control panel after login if this is the environment default
    Given feature "allow_change_of_redirection_after_login" is enabled on environment
    And I am not logged in
    And the environment is configured to redirect to profile control panel after login
    And I go to the homepage
    And I follow "Login"
    And I fill in the following:
      | Username / Email | joaosilva |
      | Password | 123456 |
    When I press "Log in"
    Then I should be on joaosilva's control panel

  @selenium
  Scenario: stay on the same page after login if this is the profile default
    Given feature "allow_change_of_redirection_after_login" is enabled on environment
    And I am not logged in
    And the environment is configured to redirect to site homepage after login
    And the profile joaosilva is configured to stay on the same page after login
    And the following users
      | login | name |
      | mariasilva | Maria Silva |
    And the following articles
      | owner      | name         | homepage |
      | mariasilva | my home page | true |
    And I go to mariasilva's homepage
    And I follow "Login"
    And I fill in the following:
      | Username / Email | joaosilva |
      | Password | 123456 |
    When I press "Log in"
    Then I should be on mariasilva's homepage

  @selenium
  Scenario: go to site homepage if this is the profile default
    Given feature "allow_change_of_redirection_after_login" is enabled on environment
    And I am not logged in
    And the environment is configured to stay on the same page after login
    And the profile joaosilva is configured to redirect to site homepage after login
    And I go to joaosilva's homepage
    And I follow "Login"
    And I fill in the following:
      | Username / Email | joaosilva |
      | Password | 123456 |
    When I press "Log in"
    Then I should be on the homepage

  @selenium
  Scenario: go to user profile after login if this is the profile default
    Given feature "allow_change_of_redirection_after_login" is enabled on environment
    And I am not logged in
    And the environment is configured to stay on the same page after login
    And the profile joaosilva is configured to redirect to user profile page after login
    And I go to the homepage
    And I follow "Login"
    And I fill in the following:
      | Username / Email | joaosilva |
      | Password | 123456 |
    When I press "Log in"
    Then I should be on joaosilva's profile

  @selenium
  Scenario: go to profile homepage after login if this is the profile default
    Given the following articles
      | owner     | name           | body               | homepage |
      | joaosilva | Sample Article | This is an article | true     |
    And feature "allow_change_of_redirection_after_login" is enabled on environment
    And I am not logged in
    And the environment is configured to stay on the same page after login
    And the profile joaosilva is configured to redirect to profile homepage after login
    And I go to the homepage
    And I follow "Login"
    And I fill in the following:
      | Username / Email | joaosilva |
      | Password | 123456 |
    When I press "Log in"
    Then I should be on joaosilva's homepage

  @selenium
  Scenario: go to profile control panel after login if this is the profile default
    Given feature "allow_change_of_redirection_after_login" is enabled on environment
    And I am not logged in
    And the environment is configured to stay on the same page after login
    And the profile joaosilva is configured to redirect to profile control panel after login
    And I go to the homepage
    And I follow "Login"
    And I fill in the following:
      | Username / Email | joaosilva |
      | Password | 123456 |
    When I press "Log in"
    Then I should be on joaosilva's control panel
