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
    Given the following Person fields are active fields
      | address  |
      | country  |
      | zip_code |
    And I go to zezinho's control panel
    And I follow "Location" within "#section-profile"
    When I fill in "Address" with "Rua Marechal Floriano, 28"
    And I select "Brazil" from "profile_data_country"
    And I fill in "profile_data[zip_code]" with "40110010"
    And I follow "Save"
    Then "zezinho" should have the following data
      | address                   | country | zip_code |
      | Rua Marechal Floriano, 28 | BR      | 40110010 |

  Scenario Outline: editing address of collectives
    Given the following <class> fields are active fields
      | address  |
      | country  |
      | zip_code |
    Given the following <plural>
      | identifier   | name    | owner   |
      | mycollective | My Collective | zezinho |
    And I am on mycollective's control panel
    And I follow "Location" within "#section-profile"
    When I select "Brazil" from "profile_data_country"
    And I fill in "profile_data[zip_code]" with "40110010"
    And I fill in "Address" with "Rua Marechal Floriano, 28"
    And I follow "Save"
    Then "mycollective" should have the following data
      | address                   | country | zip_code |
      | Rua Marechal Floriano, 28 | BR      | 40110010 |
    Examples:
      | class      | plural |
      | Community  | communities |
      | Enterprise | enterprises |

