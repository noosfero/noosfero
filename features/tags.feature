Feature: tags
  As a Noosfero user
  I want to find content tagged with a given tag
  In order to find easily the things I am looking for

  Background:
    Given the following users
      | login      |
      | josesilva  |
      | joaoaraujo |
    And the following articles
      | owner | name | body | tag_list |
      | josesilva | save the whales | ... | environment, whales |
      | joaoaraujo | the Amazon is being destroyed | ... | environment, forest, amazon |

  Scenario: viewing tag cloud
    When I go to /tag
    Then I should see "environment"
    And I should see "whales"
    And I should see "forest"
    And I should see "amazon"

  Scenario: viewing a single tag
    When I go to /tag
    And I follow "environment" within ".no-boxes"
    Then I should see "save the whales"
    And I should see "the Amazon is being destroyed"

  Scenario: viewing another tag
    When I go to /tag
    And I follow "whales"
    Then I should see "save the whales"
    And I should not see "the Amazon is being destroyed"

  Scenario: viewing profile's tag cloud
    When I go to /profile/joaoaraujo/tags
    Then I should see "amazon"
    And I should not see "whales"

  Scenario: viewing profile's content tagged
    When I go to /profile/joaoaraujo/tags/amazon
    Then I should see "the Amazon is being destroyed"
