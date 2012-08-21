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
    And I follow "Add metric"
    And I follow "Analizo"
    And I follow "Lines of Code"
    And I fill in the following:
      | Code:           | SampleCode           |
      | Weight:         | 10.0                  |
    And I select "Average" from "Aggregation Form:"
    And I press "Add"
    And I press "Save" and wait
    
  Scenario: Keep metrics after editing configuration
    When I follow "Edit" within "article-actions" and wait
    And I press "Save" 
    Then I should see "Lines of Code"
    
  #FIXME: Create new step for this scenario
  Scenario: Check if title is edit-disabled
    When I follow "Edit" within "article-actions" and wait
    And I fill in the following:
      | Title           | Some Title     |
    And I press "Save" and wait
    Then I should not see "Some Title"
    
    
  Scenario: Check if description is edit-enabled
    When I follow "Edit" within "article-actions" and wait
    And I fill in the following:
      | Description           | Some Description     |
    And I press "Save" and wait
    Then I should see "Some Description"
    And I should see "Lines of Code"
