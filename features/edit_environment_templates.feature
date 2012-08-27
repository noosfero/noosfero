Feature: edit environment templates
  As an administrator
  I want to edit templates

  Background:
    Given that the default environment have all profile templates

  Scenario: See links to edit all templates
    Given I am logged in as admin
    When I follow "Administration"
    And I follow "Profile templates"
    Then I should see "Person template" link
    And I should see "Community template" link
    And I should see "Enterprise template" link
    And I should see "Inactive Enterprise template" link

  Scenario: Go to control panel of person template
    Given I am logged in as admin
    When I follow "Administration"
    And I follow "Profile templates"
    And I follow "Person template"
    Then I should be on Person template's control panel

  Scenario: Go to control panel of enterprise template
    Given I am logged in as admin
    When I follow "Administration"
    And I follow "Profile templates"
    And I follow "Enterprise template"
    Then I should be on Enterprise template's control panel

  Scenario: Go to control panel of inactive enterprise template
    Given I am logged in as admin
    When I follow "Administration"
    And I follow "Profile templates"
    And I follow "Inactive enterprise template"
    Then I should be on Inactive Enterprise template's control panel

  Scenario: Go to control panel of community template
    Given I am logged in as admin
    When I follow "Administration"
    And I follow "Profile templates"
    And I follow "Community template"
    Then I should be on Community template's control panel

  Scenario: Not see link to edit an unexistent template
    Given that the default environment have no Inactive Enterprise template
    And I am logged in as admin
    When I follow "Administration"
    And I follow "Profile templates"
    Then I should see "Person template" link
    And I should see "Community template" link
    And I should see "Enterprise template" link
    And I should not see "Inactive enterprise template" link
