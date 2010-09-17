Feature: my_network_block
  As a blog owner
  I want to see a summary of my network

  Background:
    Given the following users
      | login     | name       |
      | joaosilva | Joao Silva |
    And the following blocks
      | owner     | type           |
      | joaosilva | MyNetworkBlock |
    And the following communities
      | identifier       | name              | public_profile |
      | public-community | Public Community  | true           |

  Scenario: display how many public/private communities I am member
    Given the following communities
      | identifier              | name                   | owner     | public_profile |
      | other-public-community  | Other Public Community | joaosilva | true           |
      | private-community       | Private Community      | joaosilva | false          |
    And I am logged in as "joaosilva"
    And I am on Joao Silva's homepage
    Then I should see "2 communities"
    When I go to Public Community's homepage
    And I follow "Join"
    When I go to Joao Silva's homepage
    Then I should see "3 communities"

  Scenario: not display how many invisible communities I am member
    Given the following communities
      | identifier            | name                  | owner     | visible |
      | visible-community     | Visible Community     | joaosilva | true    |
      | not-visible-community | Not Visible Community | joaosilva | false   |
    And I am logged in as "joaosilva"
    And I am on Joao Silva's homepage
    Then I should see "One community"
    When I go to Public Community's homepage
    And I follow "Join"
    When I go to Joao Silva's homepage
    Then I should see "2 communities"

  Scenario: display how many public/private friends I have
    Given the following users
      | login      | name        | public_profile |
      | mariasilva | Maria Silva | true           |
      | josesilva  | Jose Silva  | false          |
    And "joaosilva" is friend of "mariasilva"
    And I am logged in as "joaosilva"
    And I am on Joao Silva's homepage
    Then I should see "1 friend"
    And "joaosilva" is friend of "josesilva"
    When I go to Joao Silva's homepage
    Then I should see "2 friends"

  Scenario: not display how many invisible friends I have
    Given the following users
      | login      | name        | visible |
      | mariasilva | Maria Silva | true    |
      | josesilva  | Jose Silva  | false   |
    And "joaosilva" is friend of "mariasilva"
    And I am logged in as "joaosilva"
    When I go to Joao Silva's homepage
    Then I should see "1 friend"
    And "joaosilva" is friend of "josesilva"
    When I go to Joao Silva's homepage
    Then I should see "1 friend"
