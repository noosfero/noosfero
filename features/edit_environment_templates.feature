Feature: edit environment templates
  As an administrator
  I want to edit templates

  Background:
    Given that the default environment have all profile templates
    And I am logged in as admin
    And I am on the environment control panel

  @selenium
  Scenario: See links to edit all templates
    Given I follow "Profile templates"
    Then I should see "Person template"
    And I should see "Community template"
    And I should see "Enterprise template"
    And I should see "Inactive Enterprise template"

  @selenium
  Scenario: Go to control panel of person template
    Given I follow "Profile templates"
    And I follow "Person template"
    Then I should be on colivre.net_person_template's control panel

  @selenium
  Scenario: Go to control panel of enterprise template
    Given I follow "Profile templates"
    And I follow "Enterprise template"
    Then I should be on colivre.net_enterprise_template's control panel

  @selenium
  Scenario: Go to control panel of inactive enterprise template
    Given I follow "Profile templates"
    And I follow "Inactive Enterprise template"
    Then I should be on colivre.net_inactive_enterprise_template's control panel

  @selenium
  Scenario: Go to control panel of community template
    Given I follow "Profile templates"
    When I follow "Community template"
    Then I should be on colivre.net_community_template's control panel

  @selenium
  Scenario: Not see link to edit an unexistent template
    Given I follow "Profile templates"
    And that the default environment have no Inactive Enterprise template
    Then I should see "Person template"
    And I should see "Community template"
    And I should see "Enterprise template"
    And I should not see "Inactive enterprise template"
