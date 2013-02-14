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

  Scenario: I see Mezuro project's input form
    Given I am on mycommunity's control panel
    When I follow "Mezuro project"
    Then I should see "Title"
    And I should see "Description"

  Scenario: I create a Mezuro project with valid attributes
    Given I am on mycommunity's control panel
    When I create a Mezuro project with the following data
      | Title           | Sample Project      |
      | Description     | Sample Description  |
    Then I should see "Sample Project"
    And I should see "Sample Description"
    And I should see "Add Repository"

	@selenium 
	Scenario: I edit a Mezuro project
		Given I have a Mezuro project with the following data
      | name        | Sample Project     |
      | description | Sample Description |
      | community   | mycommunity        |
		And I am on article "Sample Project"
		And I should be on /mycommunity/sample-project
		When I follow "Edit"
    Then I should see "Sample Project" in the "article_name" input
    And I should see "Sample Description" in the "article_description" input
    And I should see "Save" button

		
#	@selenium
#	Scenario: I delete a Mezuro project that belongs to me
#		Given the following Mezuro project
#      | name               | description         | owner    |
#      | Sample Project     | Sample Description  | joaosilva |
#		And I am on article "Sample Project"
#		And I should be on /joaosilva/sample-project
#		When I follow "Delete"
#		And I confirm the "Are you sure that you want to remove the item "Sample Project"?" dialog
#		Then I go to /joaosilva/sample-project
#		And I should see "There is no such page: /joaosilva/sample-project"
#		
#  @selenium
#	Scenario: I cannot delete a Mezuro project that doesn't belong to me
#		Given the following Mezuro project
#      | name               | description         | owner    |
#      | Sample Project     | Sample Description  | joaosilva |
#		And I am on article "Sample Project"
#		And I should be on /joaosilva/sample-project
#		When I follow "Delete"
#		And I confirm the "Are you sure that you want to remove the item "Sample Project"?" dialog
#		Then I go to /joaosilva/sample-project
#		And I should see "There is no such page: /joaosilva/sample-project"
		
