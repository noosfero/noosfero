Feature: article custom fields
  As a noosfero user
  I want to add custom fields to an article

  Background:
    Given I am on the homepage
    And the following users
      | login     | name       |
      | joaosilva | Joao Silva |
    And the following articles
      | owner     | name              | body |
      | joaosilva | Save the whales   | ...  |
    And I am logged in as "joaosilva"
    And I am on joaosilva's sitemap
    And I follow "Save the whales"
    And I follow "Edit"

  @selenium
  Scenario: Add custom field to an article
    Given I follow "Add new field"
    And I select "Text" from "custom-field-type"
    And I fill in "custom-field-name" with "New field"
    When I follow "Add new field"
    Then should see "New field" within "#article-custom-fields"

  @selenium
  Scenario: Not add two custom fields with the same name
    Given I follow "Add new field"
    And I select "Text" from "custom-field-type"
    And I fill in "custom-field-name" with "New field"
    When I follow "Add new field"
    And I fill in "custom-field-name" with "New field"
    And I follow "Add new field"
    Then The page should contain only 1 "div.article-custom-field-wrapper"

  @selenium
  Scenario: Not add custom field with blank name
    Given I follow "Add new field"
    And I select "Text" from "custom-field-type"
    And I fill in "custom-field-name" with ""
    Then The page should contain only 0 "div.article-custom-field-wrapper"

  @selenium
  Scenario: Display date picker when custom field is a date
    Given I follow "Add new field"
    And I select "Date" from "custom-field-type"
    And I fill in "custom-field-name" with "New field"
    When I follow "Add new field"
    And I click "input.custom-datepicker"
    Then The page should contain only 1 ".article-custom-field-wrapper input.hasDatepicker"

  @selenium
  Scenario: Display checkbox when custom field is a boolean
    Given I follow "Add new field"
    And I select "Boolean" from "custom-field-type"
    And I fill in "custom-field-name" with "New field"
    When I follow "Add new field"
    Then The page should contain only 1 "#article-custom-fields .custom-field-input input[type=checkbox]"

  @selenium
  Scenario: Add two fields different different types
    Given I follow "Add new field"
    When I select "Boolean" from "custom-field-type"
    And I fill in "custom-field-name" with "New boolean field"
    And I follow "Add new field"
    And I select "Text" from "custom-field-type"
    And I fill in "custom-field-name" with "New text field"
    And I follow "Add new field"
    Then The page should contain only 2 "#article-custom-fields .article-custom-field-wrapper"

  @selenium
  Scenario: Remove one of the fields
    Given I follow "Add new field"
    And I select "Boolean" from "custom-field-type"
    And I fill in "custom-field-name" with "New boolean field"
    And I follow "Add new field"
    And I select "Text" from "custom-field-type"
    And I fill in "custom-field-name" with "New text field"
    And I follow "Add new field"
    When I follow "Remove field"
    Then The page should contain only 1 "#article-custom-fields .article-custom-field-wrapper"
