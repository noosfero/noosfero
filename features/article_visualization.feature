Feature: article visualization
  As a user
  I want to change view modes
  In order to see articles in fullscreen or not in fullscreen

  Background:
    Given the following users
      | login     | name       |
      | joaosilva | Joao Silva |
    And "joaosilva" has no articles
    And the following articles
      | owner     | name           | body               |
      | joaosilva | Sample Article | This is an article |
    And I am logged in as "joaosilva"

  @selenium
  Scenario: viewing the article in fullscreen by default
    Given I go to /joaosilva/sample-article?fullscreen=1
    Then I should see "Exit full screen"

  @selenium
  Scenario: viewing the article not in fullscreen by default
    Given I go to /joaosilva/sample-article
    Then I should see "Full screen"

  @selenium
  Scenario: changing the view mode from not in fullscreen to fullscreen
    Given I go to /joaosilva/sample-article
    And I follow "Full screen"
    Then I should see "Exit full screen"
