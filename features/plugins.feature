Feature: plugins
  As a noosfero\'s developer
  I want to create hot spots that a plugin should use
  As a plugins\' developer
  I want to create plugins that uses noosfero\'s hot spots
  As an admin of a noosfero environment
  I want to activate and deactivate some plugins
  As a user
  I want to use the features implemented by the plugins

  Background:
    Given the following users
      | login | name |
      | joaosilva | Joao Silva |
    And I am logged in as "joaosilva"

  Scenario: a user must see the plugin\'s button in the control panel if the plugin is enabled
    Given plugin Foo is enabled on environment
    And I go to joaosilva's control panel
    Then I should see "Foo plugin button"

  Scenario: a user must see the plugin\'s tab in in the profile if the plugin is enabled
    Given plugin Foo is enabled on environment
    And I am on joaosilva's profile
    Then I should see "Foo plugin tab"

  Scenario: a user must not see the plugin\'s button in the control panel if the plugin is disabled
    Given plugin Foo is disabled on environment
    And I go to joaosilva's control panel
    Then I should not see "Foo plugin button"

  Scenario: a user must not see the plugin\'s tab in in the profile if the plugin is disabled
    Given plugin Foo is disabled on environment
    And I am on joaosilva's profile
    Then I should not see "Foo plugin tab"

  Scenario: an admin should be able to deactivate a plugin
    Given plugin Foo is enabled on environment
    And I am logged in as admin
    When I go to admin_user's control panel
    Then I should see "Foo plugin button"
    When I go to admin_user's profile
    Then I should see "Foo plugin tab"
    And I go to the environment control panel
    And I follow "Plugins"
    And I uncheck "Foo"
    And I press "Save changes"
    When I go to admin_user's control panel
    Then I should not see "Foo plugin button"
    When I go to admin_user's profile
    Then I should not see "Foo plugin tab"
