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

  @selenium
  Scenario: seeing my enterprises on menu
    Given I am logged in as "joaosilva"
    Then I should see "My enterprises" link
    When I follow "My enterprises" and wait
    Then I should see "Tangerine Dream" linking to "/myprofile/tangerine-dream"

  @selenium
  Scenario: not show enterprises on menu to a user without enterprises
    Given I am logged in as "mariasilva"
    Then I should not see "My enterprises" link
