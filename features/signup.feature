Feature: signup
  As a new user
  I want to sign up to the site
  So I can have fun using its features

  Scenario: successfull registration
    Given I am on the homepage
    When I follow "Login"
    And I follow "I want to participate"
    And I fill in "e-Mail" with "josesilva@example.com"
    And I fill in "Username" with "josesilva"
    And I fill in "Password" with "secret"
    And I fill in "Password confirmation" with "secret"
    And I fill in "Name" with "José da Silva"
    And I press "Sign up"
    Then I should see "Thanks for signing up!"

  Scenario: be redirected if user goes to signup page and is logged
    Given the following users
      | login | name |
      | joaosilva | Joao Silva |
    Given I am logged in as "joaosilva"
    And I go to signup page
    Then I should be on Joao Silva's control panel

  Scenario: user cannot register without a name
    Given I am on the homepage
    And I follow "Login"
    And I follow "I want to participate"
    And I fill in "e-Mail" with "josesilva@example.com"
    And I fill in "Username" with "josesilva"
    And I fill in "Password" with "secret"
    And I fill in "Password confirmation" with "secret"
    And I press "Sign up"
    Then I should see "Name can't be blank"

  Scenario: user cannot change his name to empty string
    Given the following users
      | login | name |
      | joaosilva | Joao Silva |
    Given I am logged in as "joaosilva"
    And I am on Joao Silva's control panel
    And I follow "Profile Info and settings"
    And I fill in "Name" with ""
    When I press "Save"
    Then I should see "Name can't be blank"
