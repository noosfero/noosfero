@kalibro_restart
Feature: Reading
  As a Mezuro user
  I want to create, edit and remove a reading

  Background:
    Given the following users
      | login     | name       |
      | joaosilva | Joao Silva |
    And I am logged in as "joaosilva"
    And "Mezuro" plugin is enabled
    And I have a Mezuro reading group with the following data
      | name        | Sample Reading Group |
      | description | Sample Description   |
      | user        | joaosilva            |

  @selenium
  Scenario: I want to see the Mezuro reading input form
    Given I am on article "Sample Reading Group"
    When I follow "Add Reading"
    Then I should see "Sample Reading Group Reading Group" in a link
    And I should see "Label"
    And I should see "Grade"
    And I should see "Color"
    And I should see "Save" button

  @selenium
  Scenario: I try to add a reading with no name
    Given I am on article "Sample Reading Group"
    When I follow "Add Reading"
    And I fill the fields with the new following data
      | reading_label |        |
      | reading_grade | 10.2   |
      | reading_color | ABCDEF |
    And I press "Save"
    Then I should see "Please fill all fields marked with (*)." inside an alert

  @selenium
  Scenario: I try to add a reading with no grade
    Given I am on article "Sample Reading Group"
    When I follow "Add Reading"
    And I fill the fields with the new following data
      | reading_label | Useless |
      | reading_grade |         |
      | reading_color | f51313  |
    And I press "Save"
    Then I should see "Please fill all fields marked with (*)." inside an alert

  @selenium
  Scenario: I try to add a reading with no color
    Given I am on article "Sample Reading Group"
    When I follow "Add Reading"
    And I fill the fields with the new following data
      | reading_label | Fantastic |
      | reading_grade | 4.0       |
      | reading_color |           |
    And I press "Save"
    Then I should see "Please fill all fields marked with (*)." inside an alert

  @selenium
  Scenario: I want to add a reading with no color
    Given I am on article "Sample Reading Group"
    When I follow "Add Reading"
    And I fill the fields with the new following data
      | reading_label | Normal  |
      | reading_grade | 1.0     |
      | reading_color | 19cbd1  |
    And I press "Save"
    Then I should see "Normal"
    And I should see "1.0"
    And I should see the "#19cbd1" color
    And I should see "Remove"

  @selenium
  Scenario: I want to see a reading edit form
    Given I have a Mezuro reading with the following data
      | label | Simple  |
      | grade | 2.0     |
      | color | 34afe2  |
    And I am on article "Sample Reading Group"
    When I follow the edit link for "Simple" reading
    Then I should see "Simple" in the "reading_label" input
    And I should see "2.0" in the "reading_grade" input
    And I should see "34afe2" in the "reading_color" input
    And I should see "Save" button
