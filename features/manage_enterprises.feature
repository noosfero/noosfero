Feature: manage enterprises
  As a enterprise owner
  I want to manage my enterprises

  Background:
    Given the following users
      | login | name |
      | joaosilva | Joao Silva |
      | mariasilva | Joao Silva |
    And the following enterprise
      | identifier | name | owner |
      | tangerine-dream | Tangerine Dream | joaosilva |
    And feature "display_my_enterprises_on_user_menu" is enabled on environment

  @selenium
  Scenario: seeing my enterprises on menu
    Given I am logged in as "joaosilva"
    And I follow "menu-dropdown"
    Then I should see "My enterprises" link
    When I follow "My enterprises"
    Then I should see "Manage Tangerine Dream" link
    And I follow "Manage Tangerine Dream"
    Then I should be on tangerine-dream's control panel


  @selenium
  Scenario: not show enterprises on menu to a user without enterprises
    Given I am logged in as "mariasilva"
    And I follow "menu-dropdown"
    Then I should not see "My enterprises" link
