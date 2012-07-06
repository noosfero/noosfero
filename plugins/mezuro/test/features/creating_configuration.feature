Feature: Create configuration 
  As a mezuro user
  I want to create a Kalibro configuration

  Background:
    Given the following users
      | login     | name       |
      | joaosilva | Joao Silva |
    And I am logged in as "joaosilva"
    And "Mezuro" plugin is enabled
    And the following community
      | identifier  | name         |
      | mycommunity | My Community |
    And "Joao Silva" is admin of "My Community"
    
  Scenario: creating with valid attributes
    Given I am on My Community's cms
    When I create a content of type "Kalibro configuration" with the following data
      | Title           | Qt_Calculator         |
      | Description     | A sample description  |
    Then I should see "Name"
    And I should see "Qt_Calculator"
    And I should see "Description"
    And I should see "A sample description"
    
   Scenario: creating with duplicated name
    Given I am on My Community's cms
    And I create a content of type "Kalibro configuration" with the following data
      | Title           | Original Title          |
    And I am on My Community's cms
    When I create a content of type "Kalibro configuration" with the following data
      | Title           | Original Title          |
    Then I should see "1 error prohibited this article from being saved"  
    
  Scenario: creating without title
    Given I am on My Community's cms
    When I create a content of type "Kalibro configuration" with the following data
      | Title           |          |
    Then I should see "1 error prohibited this article from being saved"

