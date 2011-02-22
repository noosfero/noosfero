Feature: session and cookies handling

  As a Noosfero system administrator
  I want Noosfero to manage well it usage of sessions and cookies
  So that we can use HTTP caching effectively

  Scenario: home page, logged in
    Given the following users
      | login     |
      | joaosilva |
    When I am logged in as "joaosilva" 
    And I go to the homepage
    Then there must be a cookie "_noosfero_session"

  Scenario: home page, not logged in
    When I go to the homepage
    Then there must be no cookies

  Scenario: logout
    Given I am logged in as "joao"
    When I go to /logout
    Then there must be a cookie "auth_token"
