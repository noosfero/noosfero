Feature: Create project
  As a mezuro user
  I want to create a Mezuro project

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
    Given I am on My Community's control panel
    When I follow "Mezuro Project"
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

  Scenario: I create a Mezuro project with valid attributes
    Given I am on My Community's control panel
    When I create a Mezuro project with the following data
      | Title           | Sample Project      |
      | License         | GNU General Public License version 2.0 (GPL-2.0)                |
      | Repository type | SUBVERSION          |
      | Repository url  | https://qt-calculator.svn.sourceforge.net/svnroot/qt-calculator |
      | Configuration   | Kalibro for Java    |
    Then I should see "Sample Project"
    And I should see "GNU General Public License version 2.0 (GPL-2.0)"
    And I should see "SUBVERSION"
    And I should see "https://qt-calculator.svn.sourceforge.net/svnroot/qt-calculator"
    And I should see "Kalibro for Java"
   
  Scenario: I can't create a Mezuro project with invalid attributes
    Given I am on My Community's control panel
    When I create a Mezuro project with the following data
      | Title           |                     |
      | License         | GNU General Public License version 2.0 (GPL-2.0)                |
      | Repository type | SUBVERSION          |
      | Repository url  |                     |
      | Configuration   | Kalibro for Java    |
   Then I should see "The highlighted fields are mandatory."
   And I should see "Repository URL is mandatory"
