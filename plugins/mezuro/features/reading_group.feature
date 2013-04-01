Feature: Reading Group
  As a mezuro user
  I want to create, edit and remove a Mezuro reading group

  Background:
    Given the following users
      | login     | name       |
      | joaosilva | Joao Silva |
    Given I am logged in as "joaosilva"
    And "Mezuro" plugin is enabled

  Scenario: I see Mezuro reading group's input form
    Given I am on joaosilva's control panel
    When I follow "Mezuro reading group"
    Then I should see "Title"
    And I should see "Description"

  @kalibro_restart
  Scenario: I create a Mezuro reading group with valid attributes
    Given I am on joaosilva's control panel
    When I create a Mezuro reading group with the following data
      | Title           | Sample Reading Group |
      | Description     | Sample Description   |
    Then I should see "Sample Reading Group"
    And I should see "Sample Description"
    And I should see "Readings"
    And I should see "Add Reading"
    
  Scenario: I try to create a Mezuro reading group without title
    Given I am on joaosilva's control panel
    And I follow "Mezuro reading group"
    And the field "article_name" is empty
    When I press "Save" 
    Then I should see "Title can't be blank"

  @kalibro_restart
  Scenario: I try to create a Mezuro reading group with title already in use
    Given I have a Mezuro reading group with the following data
      | name        | Sample Reading group |
      | description | Sample Description   |
      | user        | joaosilva            | 
    And I am on joaosilva's control panel
    When I create a Mezuro reading group with the following data
      | Title           | Sample Reading Group |
      | Description     | Sample Description   |
    Then I should see "Slug The title (article name) is already being used by another article, please use another title."

  @selenium @kalibro_restart
	Scenario: I see a Mezuro reading group edit form
		Given I have a Mezuro reading group with the following data
      | name        | Sample Reading group |
      | description | Sample Description   |
      | user        | joaosilva            |
		And I am on article "Sample Reading group"
		When I follow "Edit"
    Then I should see "Sample Reading group" in the "article_name"
    And I should see "Sample Description" in the "article_description"
    And I should see "Save" button
    
  @selenium @kalibro_restart
  Scenario: I edit a Mezuro reading group with valid attributes
    Given I have a Mezuro reading group with the following data
      | name        | Sample Reading group |
      | description | Sample Description   |
      | user        | joaosilva            |
    And I am on article "Sample Reading group"    
		And I follow "Edit"
		When I fill the fields with the new following data
      | article_name        | Another Reading group |
      | article_description | Another Description   |
    And I press "Save"
    Then I should see "Another Reading group"
    And I should see "Another Description"
    And I should see "Add Reading"

  @selenium @kalibro_restart
  Scenario: I try to edit a Mezuro reading group leaving empty its title
    Given I have a Mezuro reading group with the following data
      | name        | Sample Reading group |
      | description | Sample Description   |
      | user        | joaosilva            |
    And I am on article "Sample Reading group"    
		And I follow "Edit"
    When I erase the "article_name" field
    And I press "Save"
    Then I should see "Title can't be blank"

  @selenium @kalibro_restart
  Scenario: I try to edit a Mezuro reading group with title of an existing Mezuro Reading group
    Given I have a Mezuro reading group with the following data
      | name        | Sample Reading group |
      | description | Sample Description   |
      | user        | joaosilva            |
    And I have a Mezuro reading group with the following data
      | name        | Another Reading group |
      | description | Another Description   |
      | user        | joaosilva             |
    And I am on article "Sample Reading group"    
		And I follow "Edit"
		When I fill the fields with the new following data
      | article_name        | Another Reading group |
      | article_description | Another Description   |
    And I press "Save"
    Then I should see "Slug The title (article name) is already being used by another article, please use another title."

  @selenium @kalibro_restart
	Scenario: I delete a Mezuro reading group that belongs to me
		Given I have a Mezuro reading group with the following data
      | name        | Sample Reading group |
      | description | Sample Description   |
      | user        | joaosilva            |
		And I am on article "Sample Reading group"
		When I follow "Delete"
		And I confirm the "Are you sure that you want to remove the item "Sample Reading group"?" dialog
		Then I go to /joaosilva/sample-reading-group
		And I should see "There is no such page: /joaosilva/sample-reading-group"
		
  @selenium @kalibro_restart
	Scenario: I cannot edit or delete a Mezuro reading group that doesn't belong to me
		Given I have a Mezuro reading group with the following data
      | name        | Sample Reading group |
      | description | Sample Description   |
      | user        | joaosilva            |
    And the following users
      | login     | name       |
      | adminuser | Admin      |
    And I am logged in as "adminuser"
		When I am on article "Sample Reading group"
		Then I should not see "Delete"
		And I should not see "Edit"

