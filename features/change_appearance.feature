Feature: Change appearance
  As a user
  I want to change the appearance of my profile page

  Background:
    Given the following users
      | login     | name       |
      | joaosilva | Joao Silva |
    And feature "enable_appearance" is enabled on environment

  Scenario: Change appearance from default(3 boxes) to Left Top and Right(4 boxes)
    Given I am logged in as "joaosilva"
    And I go to joaosilva's control panel
    And I follow "Edit sideboxes"
    And I should not see an element ".box-4"
    And I go to joaosilva's control panel
    And I follow "Edit Appearance"
    And I follow "Top and Side Bars"
    And I go to joaosilva's control panel
    And I follow "Edit sideboxes"
    And I should see an element ".box-4"
