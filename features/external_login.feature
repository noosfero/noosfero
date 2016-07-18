Feature: external login
  As a user
  I want to login using an account from a federated network
  In order to view pages logged in

  @selenium
  Scenario: login from portal homepage
    Given feature "allow_change_of_redirection_after_login" is disabled on environment
    And the following external environments
      | identifier | name | url                            |
      | test       | Test | http://federated.noosfero.org/ |
    And the following external users
      | login                            |
      | joaosilva@federated.noosfero.org |
    And I am not logged in
    And I go to the homepage
    And I follow "Login"
    And I fill in the following:
      | Username / Email | joaosilva@federated.noosfero.org |
      | Password         | 123456                           |
    When I press "Log in"
    Then I should be on the homepage
    And I should be externally logged in as "joaosilva@federated.noosfero.org"

  @selenium
  Scenario: not login from portal homepage
    Given feature "allow_change_of_redirection_after_login" is disabled on environment
    And the following external environments
      | identifier | name | url                            |
      | test       | Test | http://federated.noosfero.org/ |
    And I am not logged in
    And I go to the homepage
    And I follow "Login"
    And I fill in the following:
      | Username / Email | joaosilva@federated.noosfero.org |
      | Password         | 123456                           |
    When I press "Log in"
    Then I should be on /account/login
    And I should not be externally logged in as "joaosilva@federated.noosfero.org"

  @selenium
  Scenario: not login if network is not whitelisted
    Given feature "allow_change_of_redirection_after_login" is disabled on environment
    And the following external users
      | login                            |
      | joaosilva@federated.noosfero.org |
    And I am not logged in
    And I go to the homepage
    And I follow "Login"
    And I fill in the following:
      | Username / Email | joaosilva@federated.noosfero.org |
      | Password         | 123456                           |
    When I press "Log in"
    Then I should be on /account/login
    And I should not be externally logged in as "joaosilva@federated.noosfero.org"
