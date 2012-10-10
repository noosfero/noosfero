Feature: Add range to a metric configuration 
  As a mezuro user
  I want to add ranges to a Kalibro metric configuration

  Background:
    Given the following users
      | login     | name       |
      | joaosilva | Joao Silva |
    And I am logged in as "joaosilva"
    And "Mezuro" plugin is enabled
    And I go to the Control Panel
    And I create a Mezuro configuration with the following data
      | Title           | My Configuration     |
      | Description     | A sample description |
    And I follow "Add Metric"
    And I follow "Analizo"
    And I follow "Lines of Code"
    And I fill in the following:
      | Code:           | Sample Code           |
      | Weight:         | 10.0                  |
    And I select "Average" from "Aggregation Form:"
    And I press "Add"
    
  Scenario: adding a range to a metric configuration
    When I follow "New Range" and wait
    And I fill in the following:
      | (*) Label:       | label       |
      | (*) Beginning:   | 1           |
      | (*) End:         | 10          |
      | (*) Grade:       | 100         |
      | (*) Color:       | FF00FF      |
      | Comments:        | Comentário  |
    And I press "Save Range" and wait
    Then I should see "label" within "#ranges"

  Scenario: adding a range with invalid beginning field
  	When I follow "New Range" and wait
	And I fill in the following:
	  | (*) Label:       | label       |
      | (*) Beginning:   | teste       |
      | (*) End:         | 10          |
      | (*) Grade:       | 100         |
      | (*) Color:       | FF00FF      |
      | Comments:        | Comentário  |
    And I press "Save Range" and wait
	Then I should see "Beginning, End and Grade must be numeric values." inside an alert

  Scenario: adding a range with beginning greater than end
  	When I follow "New Range" and wait
	And I fill in the following:
	  | (*) Label:       | label       |
      | (*) Beginning:   | 100         |
      | (*) End:         | 10          |
      | (*) Grade:       | 100         |
      | (*) Color:       | FF00FF      |
      | Comments:        | Comentário  |
    And I press "Save Range" and wait
	Then I should see "End must be greater than Beginning." inside an alert

  Scenario: adding a range with no parameters
  	When I follow "New Range" and wait
	And I dont't fill anything
    And I press "Save Range" and wait
	Then I should see "Please fill all fields marked with (*)." inside an alert
