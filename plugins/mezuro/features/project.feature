Feature: Project
  As a mezuro user
  I want to create, edit and remove a Mezuro project

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

  Scenario: I see the Mezuro project input form
    Given I am on mycommunity's control panel
    When I follow "Mezuro project"
    Then I should see "Title"
    And I should see "Description"

  @kalibro_restart
  Scenario: I create a Mezuro project with valid attributes
    Given I am on mycommunity's control panel
    When I create a Mezuro project with the following data
      | Title           | Sample Project      |
      | Description     | Sample Description  |
    Then I should see "Sample Project"
    And I should see "Sample Description"
    And I should see "Add Repository"

  Scenario: I try to create a Mezuro project without title
    Given I am on mycommunity's control panel
    And I follow "Mezuro project"
    And the field "article_name" is empty
    When I press "Save" 
    Then I should see "Title can't be blank"

  @kalibro_restart
  Scenario: I try to create a Mezuro project with title already in use
    Given I have a Mezuro project with the following data
      | name        | Sample Project     |
      | description | Sample Description |
      | community   | mycommunity        | 
    And I am on mycommunity's control panel
    When I create a Mezuro project with the following data
      | Title           | Sample Project      |
      | Description     | Sample Description  |
    Then I should see "Slug The title (article name) is already being used by another article, please use another title."

  @selenium @kalibro_restart 
	Scenario: I see a Mezuro project edit form
		Given I have a Mezuro project with the following data
      | name        | Sample Project     |
      | description | Sample Description |
      | community   | mycommunity        |
		And I am on article "Sample Project"
		When I follow "Edit"
    Then I should see "Sample Project" in the "article_name"
    And I should see "Sample Description" in the "article_description"
    And I should see "Save" button

  @selenium @kalibro_restart
  Scenario: I edit a Mezuro project with valid attributes
    Given I have a Mezuro project with the following data
      | name        | Sample Project     |
      | description | Sample Description |
      | community   | mycommunity        |
    And I am on article "Sample Project"    
		And I follow "Edit"
    When I fill the fields with the new following data
      | article_name        | Another Project    |
      | article_description | Another Description|
    And I press "Save"
    Then I should see "Another Project"
    And I should see "Another Description"
    And I should see "Add Repository"
		
  @selenium @kalibro_restart
  Scenario: I try to edit a Mezuro project leaving empty its title
    Given I have a Mezuro project with the following data
      | name        | Sample Project     |
      | description | Sample Description |
      | community   | mycommunity        |
    And I am on article "Sample Project"    
		And I follow "Edit"
    When I erase the "article_name" field
    And I press "Save"
    Then I should see "Title can't be blank"

  @selenium @kalibro_restart
  Scenario: I try to edit a Mezuro project with title of an existing Mezuro Project
    Given I have a Mezuro project with the following data
      | name        | Sample Project     |
      | description | Sample Description |
      | community   | mycommunity        |
    And I have a Mezuro project with the following data
      | name        | Another Project     |
      | description | Another Description |
      | community   | mycommunity         |
    And I am on article "Sample Project"    
		And I follow "Edit"
    When I fill the fields with the new following data
      | article_name        | Another Project    |
      | article_description | Another Description|
    And I press "Save"
    Then I should see "Slug The title (article name) is already being used by another article, please use another title."

	@selenium @kalibro_restart
	Scenario: I delete a Mezuro project that belongs to me
		Given I have a Mezuro project with the following data
      | name        | Sample Project     |
      | description | Sample Description |
      | community   | mycommunity        |
		And I am on article "Sample Project"
		When I follow "Delete"
		And I confirm the "Are you sure that you want to remove the item "Sample Project"?" dialog
		Then I go to /mycommunity/sample-project
		And I should see "There is no such page: /mycommunity/sample-project"
		
  @selenium @kalibro_restart
	Scenario: I cannot edit or delete a Mezuro project that doesn't belong to me
		Given I have a Mezuro project with the following data
      | name        | Sample Project     |
      | description | Sample Description |
      | community   | mycommunity        |
    And the following users
      | login     | name       |
      | user      | User       |
    And I am logged in as "user"
		When I am on article "Sample Project"
		Then I should not see "Delete"
		And I should not see "Edit"
		
