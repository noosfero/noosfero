Feature: Repository
  As a Mezuro user
  I want to create, edit, remove and process a repository

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
    And I have a Mezuro project with the following data
      | name        | Sample Project      |
      | description | Sample Description  |
      | community   | mycommunity         |
    And I am on article "Sample Project"    
    And I should be on /mycommunity/sample-project
    
  Scenario: I want to see the Mezuro repository input form
    When I follow "Add Repository"
    Then I should see "Name"
    And I should see "Description"
    And I should see "License"
    And I should see "Process Period"
    And I should see "Type"
    And I should see "Address"
    And I should see "Configuration"
    And I should see "Add" button

  Scenario: I want to add a repository with no name
    Given I follow "Add Repository"
    When I fill in the following
      | Name            | |
      | Description     | My Description                                                  |
      | License         | ISC License (ISC)                                               |
      | Process Period  | Not Periodically                                                |
      | Type            | SUBVERSION                                                      |
      | Address         | https://qt-calculator.svn.sourceforge.net/svnroot/qt-calculator |
      | Configuration   | Kalibro for Java                                                |
    And I press "Add"
  
  Scenario: I want to add a repository with valid attributes
        
