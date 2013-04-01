@kalibro_restart
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
    And I have a Mezuro configuration with the following data
      | name        | Sample Configuration|
      | description | Sample Description  |
      | user        | joaosilva           |
    And I have a Mezuro reading group with the following data
      | name        | Sample Reading group |
      | description | Sample Description   |
      | user        | joaosilva            |
    And I have a Mezuro metric configuration with previous created configuration and reading group

  Scenario: I want to see the Mezuro repository input form
    Given I am on article "Sample Project"
    When I follow "Add Repository"
    Then I should see "Name"
    And I should see "Description"
    And I should see "License"
    And I should see "Process Period"
    And I should see "Type"
    And I should see "Address"
    And I should see "Configuration"
    And I should see "Add" button

  @selenium
  Scenario: I try to add a repository with no name
    Given I am on article "Sample Project"
    And I follow "Add Repository"
    When I fill the fields with the new following data
      | repository_name               |                                                                 |
      | repository_description        | My Description                                                  |
      | repository_license            | ISC License (ISC)                                               |
      | repository_process_period     | Not Periodically                                                |
      | repository_type               | SUBVERSION                                                      |
      | repository_address            | https://project.svn.sourceforge.net/svnroot/project             |
      | repository_configuration_id   | Sample Configuration                                            |
    And I press "Add"
    Then I should see "Please fill all fields marked with (*)." inside an alert

  @selenium
  Scenario: I try to add a repository with no address
    Given I am on article "Sample Project"
    And I follow "Add Repository"
    When I fill the fields with the new following data
      | repository_name               | My Name                                                         |
      | repository_description        | My Description                                                  |
      | repository_license            | ISC License (ISC)                                               |
      | repository_process_period     | Not Periodically                                                |
      | repository_type               | SUBVERSION                                                      |
      | repository_address            |                                                                 |
      | repository_configuration_id   | Sample Configuration                                            |
    And I press "Add"
    Then I should see "Please fill all fields marked with (*)." inside an alert

  @selenium
  Scenario: I try to add a repository with an invalid address
    Given I am on article "Sample Project"
    And I follow "Add Repository"
    When I fill the fields with the new following data
      | repository_name               | My Name                                                         |
      | repository_description        | My Description                                                  |
      | repository_license            | ISC License (ISC)                                               |
      | repository_process_period     | Not Periodically                                                |
      | repository_type               | GIT                                                             |
      | repository_address            | https://invalid-address.any-extension                           |
      | repository_configuration_id   | Sample Configuration                                            |
    And I press "Add"
    Then I should see "Address does not match type GIT chosen." inside an alert

  @selenium
  Scenario: I want to add a repository with valid attributes
    Given I am on article "Sample Project"
    And I follow "Add Repository"
    When I fill the fields with the new following data
      | repository_name               | My Name                                                         |
      | repository_description        | My Description                                                  |
      | repository_license            | ISC License (ISC)                                               |
      | repository_process_period     | Not Periodically                                                |
      | repository_type               | GIT                                                             |
      | repository_address            | https://github.com/user/project.git                             |
      | repository_configuration_id   | Sample Configuration                                            |
    And I press "Add"
    Then I should see "My Name"
    And I should see "My Description"
    And I should see "ISC License (ISC)"
    And I should see "Not Periodically"
    And I should see "GIT"
    And I should see "https://github.com/user/project.git"
    And I should see "Sample Configuration"
    And I should see "Status"

  @selenium
  Scenario: I want to see the repository edit form
    Given I have a Mezuro repository with the following data
      | name               | My Name                                                         |
      | description        | My Description                                                  |
      | license            | ISC License (ISC)                                               |
      | process_period     | Not Periodically                                                |
      | type               | GIT                                                             |
      | address            | https://github.com/user/project.git                             |
      | configuration_id   | Sample Configuration                                            |
    And I am on article "Sample Project"
    When I follow the edit link for "My Name" repository
    Then I should see "My Name" in the "repository_name"
    And I should see "My Description" in the "repository_description"
    And I should see "ISC License (ISC)" in the "repository_license"
    And I should see "Not Periodically" in the process period select field
    And I should see "GIT" in the "repository_type"
    And I should see "https://github.com/user/project.git" in the "repository_address"
    And I should see "Sample Configuration" in the repository configuration select field

  @selenium
  Scenario: I edit a Mezuro repository with valid attributes
    Given I have a Mezuro repository with the following data
      | name               | My Name                                                         |
      | description        | My Description                                                  |
      | license            | ISC License (ISC)                                               |
      | process_period     | Not Periodically                                                |
      | type               | GIT                                                             |
      | address            | https://github.com/user/project.git                             |
      | configuration_id   | Sample Configuration                                            |
    And I am on article "Sample Project"
    When I follow the edit link for "My Name" repository
    And I fill the fields with the new following data
      | repository_name               | Another Name                                                    |
      | repository_description        | Another Description                                             |
      | repository_license            | Apple Public Source License (APSL-2.0)                          |
      | repository_process_period     | Weekly                                                          |
      | repository_type               | SUBVERSION                                                      |
      | repository_address            | https://project.svn.sourceforge.net/svnroot/project             |
      | repository_configuration_id   | Sample Configuration                                            |
    And I press "Add"
    Then I should see "Another Name"
    And I should see "Another Description"
    And I should see "Apple Public Source License (APSL-2.0)"
    And I should see "Weekly"
    And I should see "SUBVERSION"
    And I should see "https://project.svn.sourceforge.net/svnroot/project"
    And I should see "Sample Configuration"
    
  @selenium
  Scenario: I try to edit a Mezuro repository leaving empty its title
    Given I have a Mezuro repository with the following data
      | name               | My Name                                                         |
      | description        | My Description                                                  |
      | license            | ISC License (ISC)                                               |
      | process_period     | Not Periodically                                                |
      | type               | GIT                                                             |
      | address            | https://github.com/user/project.git                             |
      | configuration_id   | Sample Configuration                                            |
    And I am on article "Sample Project"
		And I follow the edit link for "My Name" repository
    When I erase the "repository_name" field
    And I press "Add"
    Then I should see "Please fill all fields marked with (*)." inside an alert

  @selenium
  Scenario: I try to edit a Mezuro repository leaving empty its address
    Given I have a Mezuro repository with the following data
      | name               | My Name                                                         |
      | description        | My Description                                                  |
      | license            | ISC License (ISC)                                               |
      | process_period     | Not Periodically                                                |
      | type               | GIT                                                             |
      | address            | https://github.com/user/project.git                             |
      | configuration_id   | Sample Configuration                                            |
    And I am on article "Sample Project"
		And I follow the edit link for "My Name" repository
    When I erase the "repository_address" field
    And I press "Add"
    Then I should see "Please fill all fields marked with (*)." inside an alert

  @selenium
  Scenario: I try to edit a Mezuro repository with an invalid address
    Given I have a Mezuro repository with the following data
      | name               | My Name                                                         |
      | description        | My Description                                                  |
      | license            | ISC License (ISC)                                               |
      | process_period     | Not Periodically                                                |
      | type               | GIT                                                             |
      | address            | https://github.com/user/project.git                             |
      | configuration_id   | Sample Configuration                                            |
    And I am on article "Sample Project"
    When I follow the edit link for "My Name" repository
    And I fill the fields with the new following data
      | repository_name               | Another Name                                                    |
      | repository_description        | Another Description                                             |
      | repository_license            | Apple Public Source License (APSL-2.0)                          |
      | repository_process_period     | Weekly                                                          |
      | repository_type               | SUBVERSION                                                      |
      | repository_address            | https://invalid-address.any-extension                           |
      | repository_configuration_id   | Sample Configuration                                            |
    And I press "Add"
    Then I should see "Address does not match type SUBVERSION chosen." inside an alert

  @selenium
  Scenario: I try to edit a repository with an existing repository name
    Given I have a Mezuro repository with the following data
      | name               | My Name                                                         |
      | description        | My Description                                                  |
      | license            | ISC License (ISC)                                               |
      | process_period     | Not Periodically                                                |
      | type               | GIT                                                             |
      | address            | https://github.com/user/project.git                             |
      | configuration_id   | Sample Configuration                                            |
    And I have a Mezuro repository with the following data
      | name               | Another Name                                                    |
      | description        | Another Description                                             |
      | license            | Apple Public Source License (APSL-2.0)                          |
      | process_period     | Weekly                                                          |
      | type               | SUBVERSION                                                      |
      | address            | https://project.svn.sourceforge.net/svnroot/project             |
      | configuration_id   | Sample Configuration                                            |
    And I am on article "Sample Project"
    When I follow the edit link for "My Name" repository
    And I fill the fields with the new following data
      | repository_name               | Another Name                                                    |
      | repository_description        | Another Description                                             |
      | repository_license            | Apple Public Source License (APSL-2.0)                          |
      | repository_process_period     | Weekly                                                          |
      | repository_type               | SUBVERSION                                                      |
      | repository_address            | https://project.svn.sourceforge.net/svnroot/project             |
      | repository_configuration_id   | Sample Configuration                                            |
    And I press "Add"
    #Then I should see "Slug The title (article name) is already being used by another article, please use another title."
    #FIXME fix this validation

  @selenium
	Scenario: I delete a Mezuro repository of mine
    Given I have a Mezuro repository with the following data
      | name               | My Name                                                         |
      | description        | My Description                                                  |
      | license            | ISC License (ISC)                                               |
      | process_period     | Not Periodically                                                |
      | type               | GIT                                                             |
      | address            | https://github.com/user/project.git                             |
      | configuration_id   | Sample Configuration                                            |
    And I am on article "Sample Project"
		When I follow the remove link for "My Name" repository
		Then I should not see "My Name"

  @selenium
  Scenario: I try to edit or delete a Mezuro repository which doesn't belong to me
    Given I have a Mezuro repository with the following data
      | name               | My Name                                                         |
      | description        | My Description                                                  |
      | license            | ISC License (ISC)                                               |
      | process_period     | Not Periodically                                                |
      | type               | GIT                                                             |
      | address            | https://github.com/user/project.git                             |
      | configuration_id   | Sample Configuration                                            |
    And the following users
      | login     | name       |
      | zacarias  | Zacarias   |
    And I am logged in as "zacarias"
    When I am on article "Sample Project"    
    Then I should not see the edit link for "My Name" repository
    And I should not see the remove link for "My Name" repository

