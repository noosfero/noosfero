Feature: Create project
  As a mezuro user
  I want to create a Kalibro project

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

  Scenario: I see Kalibro project's input form
    Given I am on My Community's cms
    When I follow "New content"
    And I follow "Kalibro project"
    Then I should see "Title"
    And I should see "License"
    And I should see "Repository type"
    And I should see "GIT"
    And I should see "REMOTE_ZIP"
    And I should see "REMOTE_TARBALL"
    And I should see "SUBVERSION"
    And I should see "Repository url"
    And I should see "Configuration"
    And I should see "Kalibro for Java"

  Scenario: I create a Kalibro project with valid attributes
    Given I am on My Community's cms
    When I create a content of type "Kalibro project" with the following data
      | Title           | Sample Project      |
      | License         | GPL                 |
      | Repository type | SUBVERSION          |
      | Repository url  | https://qt-calculator.svn.sourceforge.net/svnroot/qt-calculator |
      | Configuration   | Kalibro for Java    |
   Then I should see "Sample Project"
   And I should see "GPL"
   And I should see "SUBVERSION"
   And I should see "https://qt-calculator.svn.sourceforge.net/svnroot/qt-calculator"
   And I should see "Kalibro for Java"
   And I directly delete content with name "Sample Project" for testing purposes
   
  Scenario: I can't create a Kalibro project with invalid attributes
    Given I am on My Community's cms
    When I create a content of type "Kalibro project" with the following data
      | Title           |                     |
      | License         | GPL                 |
      | Repository type | SUBVERSION          |
      | Repository url  |                     |
      | Configuration   | Kalibro for Java    |
   Then I should see "Title can't be blank"
   And I should see "Missing repository url"
