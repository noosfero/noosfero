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
  Scenario: I try to add a reading with an invalid color
    Given I am on article "Sample Reading Group"
    When I follow "Add Reading"
    And I fill the fields with the new following data
      | reading_label | Fantastic |
      | reading_grade | 4.0       |
      | reading_color | 1D10T4    |
    And I press "Save"
    Then I should see "This is not a valid color." inside an alert

  @selenium
  Scenario: I try to add a reading with a label which already exists
	Given I have a Mezuro reading with the following data
      | label | Simple  |
      | grade | 2.0     |
      | color | 34afe2  |
    And I am on article "Sample Reading Group"
    When I follow "Add Reading"
    And I fill the fields with the new following data
      | reading_label | Simple	  |
      | reading_grade | 4.0       |
      | reading_color | 1f0fa0    |
    And I press "Save"
    Then I should see "This label already exists! Please, choose another one." inside an alert

  @selenium
  Scenario: I try to add a reading with a grade which already exists
	Given I have a Mezuro reading with the following data
      | label | Extraordinary  |
      | grade | 10.0		   |
      | color | b4bad0		   |
    And I am on article "Sample Reading Group"
    When I follow "Add Reading"
    And I fill the fields with the new following data
      | reading_label | Super	  |
      | reading_grade | 10.0      |
      | reading_color | f0f000    |
    And I press "Save"
    Then I should see "This grade already exists! Please, choose another one." inside an alert

  @selenium
  Scenario: I want to add a reading with valid attributes
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
    Then I should see "Simple" in the "reading_label"
    And I should see "2.0" in the "reading_grade"
    And I should see "34afe2" in the "reading_color"
    And I should see "Save" button

  @selenium
  Scenario: I try to edit a reading leaving empty its title
    Given I have a Mezuro reading with the following data
      | label | Simple  |
      | grade | 2.0     |
      | color | 34afe2  |
    And I am on article "Sample Reading Group"
    When I follow the edit link for "Simple" reading
    And I erase the "reading_label" field
    And I press "Save"
    Then I should see "Please fill all fields marked with (*)." inside an alert

  @selenium
  Scenario: I try to edit a reading leaving empty its grade
    Given I have a Mezuro reading with the following data
      | label | Simple  |
      | grade | 2.0     |
      | color | 34afe2  |
    And I am on article "Sample Reading Group"
    When I follow the edit link for "Simple" reading
    And I erase the "reading_grade" field
    And I press "Save"
    Then I should see "Please fill all fields marked with (*)." inside an alert

  @selenium
  Scenario: I try to edit a reading leaving empty its color
    Given I have a Mezuro reading with the following data
      | label | Simple  |
      | grade | 2.0     |
      | color | 34afe2  |
    And I am on article "Sample Reading Group"
    When I follow the edit link for "Simple" reading
    And I erase the "reading_color" field
    And I press "Save"
    Then I should see "Please fill all fields marked with (*)." inside an alert

	@selenium
  Scenario: I try to edit a reading with an invalid color
		Given I have a Mezuro reading with the following data
      | label | Worthless  |
      | grade | 1.0 		   |
      | color | e5cad4  	 |
    And I am on article "Sample Reading Group"
    When I follow the edit link for "Worthless" reading
    And I fill the fields with the new following data
      | reading_label | Worthless 	|
      | reading_grade | 1.0       	|
      | reading_color | bu5aoooooo  |
    And I press "Save"
    Then I should see "This is not a valid color." inside an alert

  @selenium
  Scenario: I try to edit a reading with a label which already exists
    Given I have a Mezuro reading with the following data
      | label | Simple  |
      | grade | 2.0     |
      | color | 34afe2  |
    And I have a Mezuro reading with the following data
      | label | Complex |
      | grade | 5.0     |
      | color | 13deb2  |
    And I am on article "Sample Reading Group"
    When I follow the edit link for "Simple" reading
    And I fill the fields with the new following data
      | reading_label | Complex |
      | reading_grade | 2.0     |
      | reading_color | 34afe2  |
    And I press "Save"
    Then I should see "This label already exists! Please, choose another one." inside an alert

  @selenium
  Scenario: I try to edit a reading with a grade which already exists
    Given I have a Mezuro reading with the following data
      | label | Terrible |
      | grade | 0.0      |
      | color | 4feda4   |
    And I have a Mezuro reading with the following data
      | label | Perfect  |
      | grade | 10.0     |
      | color | de41b2   |
    And I am on article "Sample Reading Group"
    When I follow the edit link for "Terrible" reading
    And I fill the fields with the new following data
      | reading_label | Terrible |
      | reading_grade | 10.0     |
      | reading_color | 4feda4   |
    And I press "Save"
    Then I should see "This grade already exists! Please, choose another one." inside an alert

  @selenium
  Scenario: I want to edit a reading with valid attributes
    Given I have a Mezuro reading with the following data
      | label | Awful    |
      | grade | 2.5      |
      | color | babaca   |
    And I am on article "Sample Reading Group"
    When I follow the edit link for "Awful" reading
    And I fill the fields with the new following data
      | reading_label | Awesome  |
      | reading_grade | 10.0     |
      | reading_color | fa40fa   |
    And I press "Save"
    Then I should see "Awesome"
    And I should see "10.0"
    And I should see the "#fa40fa" color

  @selenium
  Scenario: I want to remove a reading
    Given I have a Mezuro reading with the following data
      | label | Unbelievable  |
      | grade | 9001.0        |
      | color | f0f0ca        |
    And I am on article "Sample Reading Group"
    When I follow the remove link for "Unbelievable" reading
    Then I should not see "Unbelievable"
    And I should not see "9001.0"
