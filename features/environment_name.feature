Feature: setting environment name
  As an environment administrator
  I want to change the name of the environment
  So that it appears in the window's title bar

  @selenium
  Scenario: setting environment name through administration panel
    Given I am logged in as admin
    And I follow "menu-dropdown"
    And I wait 1 seconds
    And I follow "Administration"
    And I follow "Environment settings"
    And I fill in "Site name" with "My environment"
    And I follow "Save"
    Then I should see "Environment settings updated"
