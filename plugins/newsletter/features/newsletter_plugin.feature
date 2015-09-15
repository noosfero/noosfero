Feature: newsletter plugin

  Background:
    Given the following users
      | login | name |
      | joaosilva | Joao Silva |
    And I am logged in as "joaosilva"

  Scenario: as admin I can configure plugin
    Given I am logged in as admin
    When I go to the environment control panel
    And I follow "Plugins"
    Then I should see "Configuration" linking to "/admin/plugin/newsletter"

  Scenario: in the newsletter settings I can see the field to enable/disable
    Given I am logged in as admin
    When I go to the environment control panel
    And I follow "Plugins"
    And I follow "Configuration"
    Then I should see "Enable send of newsletter to members on this environment"

  Scenario: redirect to newsletter visualization after save and visualize
    Given I am logged in as admin
    And "NewsletterPlugin" plugin is enabled
    When I go to the environment control panel
    And I follow "Plugins"
    And I follow "Configuration"
    And I press "Save and visualize"
    Then I should see "If you can't view this email, click here"
    And I should not see "Newsletter settings"

  Scenario: stay on newsletter settings page after save
    Given I am logged in as admin
    And "NewsletterPlugin" plugin is enabled
    When I go to the environment control panel
    And I follow "Plugins"
    And I follow "Configuration"
    And I press "Save"
    Then I should see "Newsletter settings"
    And I should not see "If you can't view this email, click here"
