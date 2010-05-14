Feature: profile tags
  As a Noosfero user
  I want to to view content tagged
  So that I can follow the subjects I care about

  Background:
    Given the following users
      | login    |
      | terceiro |
    And the following articles
      | owner    | name   | body           | tag_list   |
      | terceiro | text 1 | text 1 content | tag1, tag2 |
      | terceiro | text 2 | text 2 content | tag1, tag3 |

  Scenario: tag feed
    When I go to terceiro's profile
    And I follow "tag1"
    And I follow "Feed for this tag"
    Then I should see "text 1"
    And I should see "text 2"
