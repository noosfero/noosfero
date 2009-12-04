Feature: Location
  As a user
  I want to edit my address and location
  So that others can find me in the map

  Background:
    And the following users
      | login   |
      | zezinho |
    And I am logged in as "zezinho"

  Scenario: editing my address
    Given the following Person fields are enabled
      | address  |
      | country  |
      | state    |
      | city     |
      | zip_code |
    And I follow "Control panel"
    And I follow "Location"
    When I fill in "Address" with "Rua Marechal Floriano, 28"
    And I select "Brazil" from "Country"
    And I fill in "State" with "Bahia"
    And I fill in "City" with "Salvador"
    And I fill in "ZIP Code" with "40110010"
    And I press "Save"
    Then "zezinho" should have the following data
      | address                   | country | state | city     | zip_code |
      | Rua Marechal Floriano, 28 | BR      | Bahia | Salvador | 40110010 |

  Scenario Outline: editing address of collectives
    Given the following <class> fields are enabled
      | address  |
      | country  |
      | state    |
      | city     |
      | zip_code |
    Given the following <plural>
      | identifier   | name    | owner   |
      | mycollective | My Collective | zezinho |
    And I am on My Collective's control panel
    And I follow "Location"
    And I select "Brazil" from "Country"
    And I fill in the following:
      | Address   | Rua Marechal Floriano, 28 |
      | State    | Bahia                     |
      | City     | Salvador                  |
      | ZIP Code | 40110010                  |
    When I press "Save"
    Then "mycollective" should have the following data
      | address                   | country | state | city     | zip_code |
      | Rua Marechal Floriano, 28 | BR      | Bahia | Salvador | 40110010 |
    Examples:
      | class      | plural |
      | Community  | communities |
      | Enterprise | enterprises |

