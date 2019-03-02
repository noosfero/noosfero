Feature: signup
  As a new user
  I want to sign up to the site
  So I can have fun using its features

  Scenario: successful registration
    Given I am on the homepage
    When I follow "Sign up"
    And I fill in the following within ".no-boxes":
      | Email Address            | josesilva@example.com |
      | Username                 | josesilva             |
      | Password                 | secret                |
      | Type your password again | secret                |
      | Full name                | José da Silva         |
    And I follow "Create my account"
    And there are no pending jobs
    And I should receive an e-mail on josesilva@example.com
    When I go to login page
    And I fill in "Username" with "josesilva"
    And I fill in "Password" with "secret"
    And I follow "Log in"
    Then I should not be logged in as "josesilva"
    When José da Silva's account is activated
    And I go to login page
    And I fill in "Username" with "josesilva"
    And I fill in "Password" with "secret"
    And I follow "Log in"
    Then I should be logged in as "josesilva"

  @selenium
  Scenario: show error message if username is already used
    Given the following users
      | login     |
      | josesilva |
    When I go to signup page
    And I fill in "Username" with "josesilva"
		And I fill in "Email Address" with "josesilva@email.com"
    Then I should see "This login name is unavailable"

  Scenario: be redirected if user goes to signup page and is logged
    Given the following users
      | login | name |
      | joaosilva | joao silva |
    Given I am logged in as "joaosilva"
    And I go to signup page
    Then I should be on joaosilva's control panel

  Scenario: user cannot change his name to empty string
    Given the following users
      | login | name |
      | joaosilva | Joao Silva |
    Given I am logged in as "joaosilva"
    And I am on joaosilva's control panel
    And I follow "Informations" within "#section-profile"
    And I fill in "Name" with ""
    When I press "Save"
    Then I should see "Name can't be blank"
