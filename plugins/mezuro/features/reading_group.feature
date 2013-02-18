Feature: Reading Group
  As a mezuro user
  I want to create, edit and remove a Mezuro reading group

  Background:
    Given the following users
      | login     | name       |
      | joaosilva | Joao Silva |
    Given I am logged in as "joaosilva"
    And "Mezuro" plugin is enabled

  Scenario: I see Mezuro reading group's input form
    When I follow "Mezuro reading group"
    Then I should see "Title"
    And I should see "Description"

  @selenium
  Scenario: I create a Mezuro reading group with valid attributes
     Given I am on joaosilva's control panel
    When I create a Mezuro reading group with the following data
      | Title           | Sample Reading Group |
      | Description     | Sample Description   |
    Then I should see "Sample Reading Group"
    And I should see "Sample Description"
    And I should see "Readings"
    And I should see "Add Reading"
