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
    And I am on article "Sample Reading Group"

  @selenium @kalibro_restart
  Scenario: I want to see the Mezuro reading input form
    When I follow "Add Reading"
    Then I should see "Sample Reading Group Reading Group" in a link
    And I should see "Label"
    And I should see "Grade"
    And I should see "Color"
    And I should see "Save" button

  @selenium @kalibro_restart
  Scenario: I want to add a reading with no name
    When I follow "Add Reading"
    When I fill the fields with the new following data
      | reading_label |        |
      | reading_grade | 10.2   |
      | reading_color | ABCDEF |
    And I press "Save"
    Then I should see "Please fill all fields marked with (*)." inside an alert
