@mezuro
Feature: Create configuration 
  As a mezuro user
  I want to create a Mezuro configuration

  Background:
    Given the following users
      | login     | name       |
      | joaosilva | Joao Silva |
    And I am logged in as "joaosilva"
    And "Mezuro" plugin is enabled

  Scenario: I see Mezuro Configuration on my control panel
    When I go to the Control panel
    Then I should see "Mezuro configuration"

  Scenario: I see an empty set of clone configurations
    When I go to the Control panel
    And there is no previous configurations created
    And I follow "Mezuro configuration"
    Then I should see "None"
    And I should not see "error"

  Scenario: creating with valid attributes
    When I go to the Control panel
    And I create a Mezuro configuration with the following data
      | Title           | Qt_Calculator         |
      | Description     | A sample description  |
    Then I should see "Name"
    And I should see "Qt_Calculator"
    And I should see "Description"
    And I should see "A sample description"

  Scenario: I see a set of clone configurations
    When I go to the Control panel
    And I follow "Mezuro configuration"
    Then I should see "None"
    And I should not see "error"

   Scenario: creating with duplicated name
    When I go to the Control panel
    And I create a Mezuro configuration with the following data
      | Title           | Original Title          |
    And I go to the Control panel
    And I create a Mezuro configuration with the following data
      | Title           | Original Title          |
    Then I should see "1 error prohibited this article from being saved"  

  Scenario: creating without title
    When I go to the Control panel
    And I create a Mezuro configuration with the following data
      | Title           |          |
    Then I should see "1 error prohibited this article from being saved"

