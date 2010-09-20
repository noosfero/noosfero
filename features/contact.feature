Feature: contact organization
As a user
I want to contact an organization
In order to ask questions and solve problems

  Background:
    Given the following users
      | login | name |
      | joaosilva | Joao Silva |
    And the following communities
      | identifier | name |
      | sample-community | Sample Community |
    And I am logged in as "joaosilva" 

  Scenario: without states
    Given I am on Sample Community's homepage
    When I follow "Send an e-mail"
    Then I should not see "City and state"

  Scenario: with states
    Given the following states
      | name  |
      | Bahia |
    And I am on Sample Community's homepage
    When I follow "Send an e-mail"
    Then I should see "City and state"
    
