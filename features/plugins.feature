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
    And the following plugin
      | klass       |
      | TestPlugin  |
    And the following events of TestPlugin
      | event                 | body                                                                                                     |
      | control_panel_buttons | lambda { {:title => 'Test plugin button', :icon => '', :url => ''} }                                     |
      | profile_tabs          | lambda { {:title => 'Test plugin tab', :id => 'test_plugin', :content => 'Test plugin random content'} } |

  Scenario: a user must see the plugin\'s button in the control panel if the plugin is enabled
    Given plugin TestPlugin is enabled on environment
    And I go to Joao Silva's control panel
    Then I should see "Test plugin button"

  Scenario: a user must see the plugin\'s tab in in the profile if the plugin is enabled
    Given plugin TestPlugin is enabled on environment
    And I am on Joao Silva's profile
    Then I should see "Test plugin tab"

  Scenario: a user must not see the plugin\'s button in the control panel if the plugin is disabled
    Given plugin TestPlugin is disabled on environment
    And I go to Joao Silva's control panel
    Then I should not see "Test plugin button"

  Scenario: a user must not see the plugin\'s tab in in the profile if the plugin is disabled
    Given plugin TestPlugin is disabled on environment
    And I am on Joao Silva's profile
    Then I should not see "Test plugin tab"

  Scenario: an admin should be able to deactivate a plugin
    Given plugin TestPlugin is enabled on environment
    And I am logged in as admin
    When I go to the Control panel
    Then I should see "Test plugin button"
    When I go to the profile
    Then I should see "Test plugin tab"
    And I go to the environment control panel
    And I follow "Enable/disable plugins"
    And I uncheck "Test plugin"
    And I press "Save changes"
    When I go to the Control panel
    Then I should not see "Test plugin button"
    When I go to the profile
    Then I should not see "Test plugin tab"
