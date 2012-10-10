Feature: Remove a metric configuration from a configuration 
  As a mezuro user
  I want to remove metric configurations from a configuration

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
    When I follow "Add metric"
    And I follow "Analizo"
    And I follow "Lines of Code"
    And I fill in the following:
      | Code:           | Sample Code           |
      | Weight:         | 10.0                  |
    And I select "Average" from "Aggregation Form:"
    And I press "Add"
    And I press "Save"
    And I should see "Lines of Code"
    
    Scenario: I remove a metric configuration
    When I follow "Remove"
    Then I should not see "Lines of Code"
