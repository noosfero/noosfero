Feature: Configuration 
  As a mezuro user
  I want to create, edit and remove a Mezuro configuration

   Background:
    Given the following users
      | login     | name       |
      | joaosilva | Joao Silva |
    Given I am logged in as "joaosilva"
    And "Mezuro" plugin is enabled

  Scenario: I see Mezuro configurantion's input form
    Given I am on joaosilva's control panel
    When I follow "Mezuro configuration"
    Then I should see "Title"
    And I should see "Description"
    And I should see "Clone Configuration"

  @selenium @kalibro_restart
  Scenario: I create a Mezuro configuration with valid attributes without cloning
    Given I am on joaosilva's control panel
    And I follow "Mezuro configuration"
    When I fill the fields with the new following data
      | article_name                      | Sample Configuration |
      | article_description               | Sample Description   |
      | article_configuration_to_clone_id | None                 |
    And I press "Save"
    Then I should see "Sample Configuration"
    And I should see "Sample Description"
    And I should see "Add Metric"

  @selenium @kalibro_restart
  Scenario: I create a Mezuro configuration with valid attributes with cloning
    Given I have a Mezuro configuration with the following data
      | name        | Sample Configuration|
      | description | Sample Description  |
      | user        | joaosilva           |
    And I have a Mezuro reading group with the following data
      | name        | Sample Reading group |
      | description | Sample Description   |
      | user        | joaosilva            |
    And I have a Mezuro metric configuration with previous created configuration and reading group
    And I am on joaosilva's control panel
    And I follow "Mezuro configuration"
    When I fill the fields with the new following data
      | article_name                      | Another Configuration |
      | article_description               | Another Description   |
      | article_configuration_to_clone_id | Sample Configuration  |
    And I press "Save"
    Then I should see "Another Configuration"
    And I should see "Another Description"
    And I should see "Total Coupling Factor"
    And I should see "Add Metric"

  Scenario: I try to create a Mezuro configuration without title
    Given I am on joaosilva's control panel
    And I follow "Mezuro configuration"
    And the field "article_name" is empty
    When I press "Save" 
    Then I should see "Title can't be blank"

  @kalibro_restart
  Scenario: I try to create a Mezuro configuration with title already in use
    Given I have a Mezuro configuration with the following data
      | name        | Sample Configuration |
      | description | Sample Description   |
      | user        | joaosilva            | 
    And I am on joaosilva's control panel
    When I create a Mezuro configuration with the following data
      | Title           | Sample Configuration |
      | Description     | Sample Description   |
      | Clone           | None                 |
    Then I should see "Slug The title (article name) is already being used by another article, please use another title."

  @selenium @kalibro_restart
	Scenario: I see a Mezuro configuration edit form
		Given I have a Mezuro configuration with the following data
      | name        | Sample Configuration |
      | description | Sample Description   |
      | user        | joaosilva            |
		And I am on article "Sample Configuration"
		When I follow "Edit"
    Then I should see "Sample Configuration" in the "article_name"
    And I should see "Sample Description" in the "article_description"
    And I should see "Save" button

  @selenium @kalibro_restart
  Scenario: I edit a Mezuro configuration with valid attributes
    Given I have a Mezuro configuration with the following data
      | name        | Sample Configuration |
      | description | Sample Description   |
      | user        | joaosilva            |
    And I am on article "Sample Configuration"    
		And I follow "Edit"
		When I fill the fields with the new following data
      | article_name        | Another Configuration |
      | article_description | Another Description   |
    And I press "Save"
    Then I should see "Another Configuration"
    And I should see "Another Description"
    And I should see "Add Metric"

  @selenium @kalibro_restart
  Scenario: I try to edit a Mezuro configuration leaving empty its title
    Given I have a Mezuro configuration with the following data
      | name        | Sample Configuration |
      | description | Sample Description   |
      | user        | joaosilva            |
    And I am on article "Sample Configuration"    
		And I follow "Edit"
    When I erase the "article_name" field
    And I press "Save"
    Then I should see "Title can't be blank"

  @selenium @kalibro_restart
  Scenario: I try to edit a Mezuro configuration with title of an existing Mezuro Configuration
    Given I have a Mezuro configuration with the following data
      | name        | Sample Configuration |
      | description | Sample Description   |
      | user        | joaosilva            |
    And I have a Mezuro configuration with the following data
      | name        | Another Configuration |
      | description | Another Description   |
      | user        | joaosilva             |
    And I am on article "Sample Configuration"    
		And I follow "Edit"
		When I fill the fields with the new following data
      | article_name        | Another Configuration |
      | article_description | Another Description   |
    And I press "Save"
    Then I should see "Slug The title (article name) is already being used by another article, please use another title."

  @selenium @kalibro_restart
	Scenario: I delete a Mezuro configuration that belongs to me
		Given I have a Mezuro configuration with the following data
      | name        | Sample Configuration |
      | description | Sample Description   |
      | user        | joaosilva            |
		And I am on article "Sample Configuration"
		When I follow "Delete"
		And I confirm the "Are you sure that you want to remove the item "Sample Configuration"?" dialog
		Then I go to /joaosilva/sample-configuration
		And I should see "There is no such page: /joaosilva/sample-configuration"

  @selenium @kalibro_restart
	Scenario: I cannot edit or delete a Mezuro configuration that doesn't belong to me
		Given I have a Mezuro configuration with the following data
      | name        | Sample Configuration |
      | description | Sample Description   |
      | user        | joaosilva            |
    And the following users
      | login     | name       |
      | adminuser | Admin      |
    And I am logged in as "adminuser"
		When I am on article "Sample Configuration"
		Then I should not see "Delete"
		And I should not see "Edit"

