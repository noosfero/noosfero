Feature: newsletter plugin

  Background:
    Given I am logged in as admin

  Scenario: as admin I can configure plugin
    When I go to the environment control panel
    And I follow "Plugins"
    Then I should see "Configuration" linking to "/admin/plugin/newsletter"

  Scenario: in the newsletter settings I can see the field to enable/disable
    When I go to the environment control panel
    And I follow "Plugins"
    And I follow "Configuration"
    Then I should see "Enable send of newsletter to members on this environment"

  Scenario: redirect to newsletter visualization after save and visualize
    Given "NewsletterPlugin" plugin is enabled
    When I go to the environment control panel
    And I follow "Plugins"
    And I follow "Configuration"
    And I press "Save and visualize"
    Then I should see "If you can't view this email, click here"
    And I should not see "Newsletter settings"

  Scenario: stay on newsletter settings page after save
    Given "NewsletterPlugin" plugin is enabled
    When I go to the environment control panel
    And I follow "Plugins"
    And I follow "Configuration"
    And I press "Save"
    Then I should see "Newsletter settings"
    And I should not see "If you can't view this email, click here"

  @selenium
  Scenario: search community and select blog for newsletter
    Given the following communities
      | identifier | name |
      | sample-community | Sample Community |
    And the following blogs
      | owner | name |
      | sample-community | Sample Blog |
    And "NewsletterPlugin" plugin is enabled
    When I go to the environment control panel
    And I follow "Plugins"
    And I follow "Configuration"
    And I type in "Sample Community" into autocomplete list "search-profiles" and I choose "Sample Blog in Sample Community"
    And I press "Save"
    Then I should see "Sample Blog in Sample Community"

  @selenium
  Scenario: search profile and select blog for newsletter
    Given the following users
      | login | name |
      | joaosilva | Joao Silva |
    And the following blogs
      | owner | name |
      | joaosilva | Joao Blog |
    And "NewsletterPlugin" plugin is enabled
    When I go to the environment control panel
    And I follow "Plugins"
    And I follow "Configuration"
    And I type in "Silva" into autocomplete list "search-profiles" and I choose "Joao Blog in Joao Silva"
    And I press "Save"
    Then I should see "Joao Blog in Joao Silva"

  @selenium
  Scenario: search blog and select it for newsletter
    Given the following communities
      | identifier | name |
      | sample-community | Sample Community |
    And the following blogs
      | owner | name |
      | sample-community | Sample Blog |
    And "NewsletterPlugin" plugin is enabled
    When I go to the environment control panel
    And I follow "Plugins"
    And I follow "Configuration"
    And I type in "Sample Blog" into autocomplete list "search-profiles" and I choose "Sample Blog in Sample Community"
    And I press "Save"
    Then I should see "Sample Blog in Sample Community"
