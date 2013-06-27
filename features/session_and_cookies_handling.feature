Feature: session and cookies handling

  As a Noosfero system administrator
  I want Noosfero to manage well it usage of sessions and cookies
  So that we can use HTTP caching effectively

  @fixme
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

  @fixme
  Scenario: user_data, not logged in
    When I make a AJAX request to the user data path
    Then there must be no cookies

  @fixme
  Scenario: user_data, logged in
    Given I am logged in as admin
    When I make a AJAX request to the user data path
    Then there must be a cookie "_noosfero_session"

  # FIXME for some reason I could not test this scenario, although manual tests
  # indicate this works!
  # Scenario: logout
  #   Given the following users
  #     | login |
  #     | joao |
  #   When I am logged in as "joao"
  #   And I log off
  #   And I go to the homepage
  #   Then there must be no cookies
