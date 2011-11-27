Feature: setting environment name
  As an environment administrator
  I want to change the name of the environment
  So that it appears in the window's title bar

  Scenario: setting environment name through administration panel
    Given I am logged in as admin
    When I follow "Administration"
    And I follow "Edit environment settings"
    And I fill in "Site name" with "My environment"
    And I press "Save"
    Then I should see "My environment" within "title"
