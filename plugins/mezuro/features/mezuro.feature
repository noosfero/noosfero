Feature: mezuro content
  As a noosfero user
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

  Scenario: I see Kalibro project as an option to new content
    Given I am on My Community's cms
    When I follow "New content"
    Then I should see "Kalibro project"

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

  Scenario: I create a sample mezuro content
    Given I am on My Community's cms
    When I create a content of type "Kalibro project" with the following data
      | Title           | Sample project          |
      | License         | BSD                     |
      | Repository type | GIT                     |
      | Repository url  | git://example           |
    Then I should see "Sample project"
    And I should see "Viewed one time"
    And I should see "BSD"

  Scenario: I create a real mezuro content
    Given I am on My Community's cms
    When I create a content of type "Kalibro project" with the following data
      | Title           | Qt-Calculator           |
      | License         | GPL 2.0                 |
      | Repository type | SUBVERSION              |
      | Repository url  | https://qt-calculator.svn.sourceforge.net/svnroot/qt-calculator |
    Then I should see "Qt-Calculator"

  Scenario: I see results from a real Kalibro project
    Given I am on My Community's cms
    When I create a content of type "Kalibro project" with the following data
      | Title           | Qt-Calculator           |
      | License         | GPL                     |
      | Repository type | SUBVERSION              |
      | Repository url  | https://qt-calculator.svn.sourceforge.net/svnroot/qt-calculator |
      | Configuration   | Kalibro for Java        |
   Then I should see "Qt-Calculator"
   And I should see "GPL"
   And I should see "SUBVERSION"
   And I should see "https://qt-calculator.svn.sourceforge.net/svnroot/qt-calculator"
   And I should see "Kalibro for Java"
   And I should see "Kalibro Service is loading the source code"
