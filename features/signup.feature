Feature: signup
  As a new user
  I want to sign up to the site
  So I can have fun using its features

  Scenario: successfull registration
    Given I am on the homepage
    When I follow "Login"
    And I follow "I want to participate"
    And I fill in "e-Mail" with "ze@example.com"
    And I fill in "Username" with "ze"
    And I fill in "Password" with "secret"
    And I fill in "Password confirmation" with "secret"
    And I fill in "Full name" with "José da Silva"
    And I press "Sign up"
    Then I should see "Thanks for signing up!"

