Feature: search contents
  As a noosfero user
  I want to vote in some content

  Background:
    Given the following users
      | login     | name       |
      | joaosilva | Joao Silva |
    And "joaosilva" has no articles
    And the following articles
      | owner     | name           | body               |
      | joaosilva | Sample Article | This is an article |
    And plugin Vote is enabled on environment
    And I am logged in as "joaosilva"

  @selenium
  Scenario: liking an article
    Given I go to /joaosilva/sample-article
    And I click ".like-action a"
    Then I should see "1" within ".like-action .like-action-counter"
    And I should see "0" within ".dislike-action .like-action-counter"

  @selenium
  Scenario: liking an article
    Given I go to /joaosilva/sample-article
    And I click ".dislike-action a"
    Then I should see "0" within ".like-action .like-action-counter"
    And I should see "1" within ".dislike-action .like-action-counter"
