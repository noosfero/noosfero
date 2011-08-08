Feature: send_email_plugin

  Background:
    Given the following users
      | login | name |
      | joaosilva | Joao Silva |
    And I am logged in as "joaosilva"

  Scenario: expand macro in article content
    Given plugin SendEmailPlugin is enabled on environment
    And the following articles
      | owner | name | body |
      | joaosilva | sample-article | URL path to {sendemail} action |
    When I go to /joaosilva/sample-article
    Then I should see "URL path to /profile/joaosilva/plugins/send_email/deliver action"

  Scenario: expand macro in block content
    Given plugin SendEmailPlugin is enabled on environment
    And the following blocks
      | owner     | type         | html |
      | joaosilva | RawHTMLBlock | URL path to {sendemail} action |
    When I go to Joao Silva's homepage
    Then I should see "URL path to /profile/joaosilva/plugins/send_email/deliver action"

  Scenario: as admin I can configure plugin
    Given I am logged in as admin
    When I go to the environment control panel
    And I follow "Enable/disable plugins"
    Then I should see "SendEmailPlugin" linking to "/admin/plugin/send_email"

  Scenario: configure plugin to allow emails to john@example.com
    Given I am logged in as admin
    And I go to the environment control panel
    And I follow "Enable/disable plugins"
    When I follow "SendEmailPlugin"
    Then I should not see "john@example.com"
    When I fill in "E-Mail addresses you want to allow to send" with "john@example.com"
    And I press "Save"
    Then I should be on /admin/plugins
    When I follow "SendEmailPlugin"
    Then I should see "john@example.com"
