Feature: manage categories
  As an administrator
  I want to manage the categories

  Background:
    Given the following categories
      | name       | display_in_menu |
      | Food       | true            |
      | Book       | true            |
    And the following categories
      | parent  | name        | display_in_menu |
      | Food    | Vegetarian  | true            |
      | Food    | Steak       | true            |
    Given I am logged in as admin

  @selenium
  Scenario: admin user could access new category
    Given I follow "Administration"
    When I follow "Manage Categories"
    And I follow "New category" and wait
    Then I should be on /admin/categories/new

  @selenium
  Scenario: admin user could create a category
    Given I visit "/admin/categories/new" and wait
    When I fill in "Name" with "Category 1"
    And I press "Save"
    Then I should see "Categories"
    And I should see "Category 1"

  @selenium
  Scenario: admin user could see all the category tree
    Given I follow "Administration"
    And I follow "Manage Categories"
    When I follow "Show"
    Then I should see "Vegetarian"
    And I should see "Steak"

  @selenium
  Scenario: admin user could hide the category tree
    Given I follow "Administration"
    And I follow "Manage Categories"
    When I follow "Show"
    Then I should see "Vegetarian"
    And I should see "Steak"
    When I follow "Hide"
    Then I should not see "Vegetarian"
    And I should not see "Steak"

  @selenium
  Scenario: the show link is available just for categories with category tree
    Given the following category
      | parent  | name     | display_in_menu |
      | Steak   | Pig      | true            |
    And I am on the homepage
    When I follow "Administration"
    And I follow "Manage Categories"
    Then I should see "Food Show"
    When I follow "Show"
    Then I should see "Vegetarian"
    And I should not see "Vegetarian Show"
    And I should see "Steak Show"
