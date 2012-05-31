Feature: editing a configuration 
  As a mezuro user
  I want to edit a Kalibro configuration

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
    And I am on My Community's cms
    And I create a content of type "Kalibro configuration" with the following data
      | Title           | My Configuration     |
      | Description     | A sample description |
      
  Scenario: adding a metric configuration
    When I follow "Add metric"
    And I follow "Analizo"
    And I follow "Lines of Code"
    And I fill in the following:
      | Code:           | Sample Code           |
      | Weight:         | 10.0                  |
    And I select "Average" from "Aggregation:"
    And I press "Add"
    Then I should see "Lines of Code"
    And I should see "Analizo"
    And I should see "Sample Code"        
