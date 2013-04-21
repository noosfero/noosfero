Feature: browse
  As a noosfero visitor
  I want to browse people and communities

  Background:
    Given I am on the homepage
    And the search index is empty
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
    Given I should not see "More recent"
    And I should not see "More active"
    And I should not see "More popular"
    And display "#submenu-people-trigger"
    When I follow "submenu-people-trigger"
    Then I should see "More recent"
    And I should see "More active"
    And I should see "More popular"

  @selenium
  Scenario: People browse menu should add logged information
    Given I am logged in as "joaosilva"
    And I should not see "More recent"
    And I should not see "More active"
    And I should not see "More popular"
    And I should not see "Invite friends"
    And I should not see "My friends"
    And display "#submenu-people-trigger"
    When I follow "submenu-people-trigger"
    Then I should see "More recent"
    And I should see "More active"
    And I should see "More popular"
    And I should see "Invite friends"
    And I should see "My friends"

  Scenario: Browse people by query
    Given I go to /search/people
    When I fill in "Silva" for "search-input"
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
    Then I should not see "More recent"
    And I should not see "More active"
    And I should not see "More popular"
    And I should not see "My communities"
    And I should not see "New community"
    And display "#submenu-communities-trigger"
    When I follow "submenu-communities-trigger"
    Then I should see "More recent"
    And I should see "More active"
    And I should see "More popular"
    And I should see "My communities"
    And I should see "New community"

  @selenium
  Scenario: Show communities browse menu
    Given I should not see "More recent"
    And I should not see "More active"
    And I should not see "More popular"
    And display "#submenu-communities-trigger"
    When I follow "submenu-communities-trigger"
    Then I should see "More recent"
    And I should see "More active"
    And I should see "More popular"

  Scenario: Browse communities by query
    When I go to /search/communities
    And I fill in "Neto" for "search-input"
    And I press "Search"
    Then I should see "Community Neto"
    And I should not see "Joao Silva"
    And I should not see "Pedro Silva"
    And I should not see "Paulo Neto"
    And I should not see "Community Silva"

  @selenium
  Scenario: Show contents browse menu
    Given I should not see "Most commented"
    And I should not see "More viewed"
    And I should not see "More recent"
    And display "#submenu-contents-trigger"
    When I follow "submenu-contents-trigger"
    Then I should see "Most commented"
    And I should see "More viewed"
    And I should see "More recent"

  Scenario: Browse contents by query
    Given the following articles
      | owner     | name                      | body                    |
      | joaosilva | Bees can fly              | this is an article      |
      | joaosilva | Bees and ants are insects | this is another article |
      | joaosilva | Ants are small            | this is another article |
    When I go to /search/contents
    And I fill in "bees" for "search-input"
    And I press "Search"
    Then I should see "Bees can fly"
    And I should see "Bees and ants are insects"
    And I should not see "Ants are small"
