Feature: Add metric configuration to a configuration 
  As a mezuro user
  I want to add metric configurations to a Kalibro configuration

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
      
  Scenario: adding a native metric configuration
    When I follow "Add metric"
    And I follow "Analizo"
    And I follow "Lines of Code"
    And I fill in the following:
      | Code:           | Sample Code           |
      | Weight:         | 10.0                  |
    And I select "Average" from "Aggregation Form:"
    And I press "Add"
    Then I should see "Lines of Code"
    And I should see "Analizo"
    And I should see "Sample Code"
    
  Scenario: adding a native metric configuration without code
    When I follow "Add metric"
    And I follow "Analizo"
    And I follow "Number of Children"
    And I don't fill anything
    And I press "Add"
    Then I should be at the url "/myprofile/my-community/plugin/mezuro/new_metric_configuration"
    
  Scenario: adding a compound metric configuration
    When I follow "Add metric"
    And I follow "New Compound Metric"
    And I fill in the following:
      | Name:           | Compound sample   |
      | Description:    | 10.0              |
      | Script:         | return 42;        |
      | Code:           | anyCode           |
      | Weight:         | 10.0              |
    And I select "Class" from "Scope:"
    And I select "Average" from "Aggregation Form:"
    And I press "Add"
    Then I should see "Compound sample"
    
  Scenario: adding a compound metric configuration with invalid script
    When I follow "Add metric"
    And I follow "New Compound Metric"
    And I fill in the following:
      | Name:           | Compound sample   |
      | Description:    | 10.0              |
      | Script:         | invalid script    |
      | Code:           | anyCode           |
      | Weight:         | 10.0              |
    And I select "Class" from "Scope:"
    And I select "Average" from "Aggregation Form:"
    And I press "Add"
    Then I should see "Compound sample"
