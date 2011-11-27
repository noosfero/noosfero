Feature: edit environment templates
  As an administrator
  I want edit templates

  Background:
    Given that the default environment have all profile templates

  Scenario: See links to edit all templates
    Given I am logged in as admin
    When I follow "Administration"
    And I follow "Edit Templates"
    Then I should see "Edit Person Template" link
    And I should see "Edit Community Template" link
    And I should see "Edit Enterprise Template" link
    And I should see "Edit Inactive Enterprise Template" link

  Scenario: Go to control panel of person template
    Given I am logged in as admin
    When I follow "Administration"
    And I follow "Edit Templates"
    And I follow "Edit Person Template"
    Then I should be on Person template's control panel

  Scenario: Go to control panel of enterprise template
    Given I am logged in as admin
    When I follow "Administration"
    And I follow "Edit Templates"
    And I follow "Edit Enterprise Template"
    Then I should be on Enterprise template's control panel

  Scenario: Go to control panel of inactive enterprise template
    Given I am logged in as admin
    When I follow "Administration"
    And I follow "Edit Templates"
    And I follow "Edit Inactive Enterprise Template"
    Then I should be on Inactive Enterprise template's control panel

  Scenario: Go to control panel of community template
    Given I am logged in as admin
    When I follow "Administration"
    And I follow "Edit Templates"
    And I follow "Edit Community Template"
    Then I should be on Community template's control panel

  Scenario: Not see link to edit an unexistent template
    Given that the default environment have no Inactive Enterprise template
    And I am logged in as admin
    When I follow "Administration"
    And I follow "Edit Templates"
    Then I should see "Edit Person Template" link
    And I should see "Edit Community Template" link
    And I should see "Edit Enterprise Template" link
    And I should not see "Edit Inactive Enterprise Template" link
