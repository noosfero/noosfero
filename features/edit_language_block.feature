Feature: edit language of block
  As a profile owner
  I want to configure in which language a block will be displayed

  Background:
    Given the following users
      | login     | name       |
      | joaosilva | Jose Silva |
    And the following blocks
      | owner     | type          |
      | joaosilva | ArticleBlock  |
      | joaosilva | LinkListBlock |
    And I am logged in as "joaosilva"

  Scenario: display in all languages
    Given I go to edit ArticleBlock of joaosilva
    And I fill in "Custom title for this block" with "Block displayed"
    And I select "all languages"
    And I press "Save"
    When I go to Jose Silva's homepage
    Then I should see "Block displayed"

  Scenario: display in the selected language
    Given I go to edit LinkListBlock of joaosilva
    And I fill in "Custom title for this block" with "Block displayed"
    And I select "English"
    And I press "Save"
    And my browser prefers English
    When I go to Jose Silva's homepage
    Then I should see "Block displayed"

  Scenario: not display in a not selected language
    Given I go to edit LinkListBlock of joaosilva
    And I fill in "Custom title for this block" with "Block not displayed"
    And I select "English"
    And I press "Save"
    And my browser prefers Portuguese
    When I go to Jose Silva's homepage
    Then I should not see "Block displayed"
