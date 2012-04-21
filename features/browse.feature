Feature: browse
  As a noosfero visitor
  I want to browse people and communities

  Background:
    Given I am on the homepage
    And the following users
      | login | name |
      | joaosilva | Joao Silva |
      | pedrosilva | Pedro Silva |
      | pauloneto | Paulo Neto |
    And the following communities
      | identifier | name |
      | comunity-silva | Community Silva |
      | comunity-neto | Community Neto |

  @selenium
  Scenario: Show people browse menu
    Given I should not see "More Recent"
    And I should not see "More Active"
    And I should not see "More Popular"
    When I click "#submenu-people-trigger"
    Then I should see "More Recent"
    And I should see "More Active"
    And I should see "More Popular"

  @selenium
  Scenario: People browse menu should add logged information
    Given I am logged in as "joaosilva"
    And I should not see "More Recent"
    And I should not see "More Active"
    And I should not see "More Popular"
    And I should not see "Invite friends"
    And I should not see "My friends"
    When I click "#submenu-people-trigger"
    Then I should see "More Recent"
    And I should see "More Active"
    And I should see "More Popular"
    And I should see "Invite friends"
    And I should see "My friends"

  Scenario: Browse people by query
    Given I go to /browse/people
    When I fill in "Silva" for "query"
    And I press "Search"
    Then I should see "Joao Silva"
    And I should see "Pedro Silva"
    And I should not see "Paulo Neto"
    And I should not see "Community Silva"
    And I should not see "Community Neto"

  @selenium
  Scenario: Communities browse menu should add logged information
    Given I am logged in as "joaosilva"
    When I go to /joaosilva
    Then I should not see "More Recent"
    And I should not see "More Active"
    And I should not see "More Popular"
    And I should not see "My communities"
    And I should not see "New community"
    When I click "#submenu-communities-trigger"
    Then I should see "More Recent"
    And I should see "More Active"
    And I should see "More Popular"
    And I should see "My communities"
    And I should see "New community"

  @selenium
  Scenario: Show communities browse menu
    Given I should not see "More Recent"
    And I should not see "More Active"
    And I should not see "More Popular"
    When I click "#submenu-communities-trigger"
    Then I should see "More Recent"
    And I should see "More Active"
    And I should see "More Popular"

  Scenario: Browse communities by query
    When I go to /browse/communities
    And I fill in "Neto" for "query"
    And I press "Search"
    Then I should see "Community Neto"
    And I should not see "Joao Silva"
    And I should not see "Pedro Silva"
    And I should not see "Paulo Neto"
    And I should not see "Community Silva"

  @selenium
  Scenario: Show contents browse menu
    Given I should not see "More Comments"
    And I should not see "More Views"
    And I should not see "More Recent"
    When I click "#submenu-contents-trigger"
    Then I should see "More Comments"
    And I should see "More Views"
    And I should see "More Recent"

  Scenario: Browse contents by query
    Given the following articles
      | owner     | name                      | body                    |
      | joaosilva | Bees can fly              | this is an article      |
      | joaosilva | Bees and ants are insects | this is another article |
      | joaosilva | Ants are small            | this is another article |
    When I go to /browse/contents
    And I fill in "bees" for "query"
    And I press "Search"
    Then I should see "Bees can fly"
    And I should see "Bees and ants are insects"
    And I should not see "Ants are small"
