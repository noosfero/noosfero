Feature: rate_community
  As a user
  I want to be able rate a community
  So that users can see my feedback about that community

  Background:
    Given plugin "OrganizationRatings" is enabled on environment
    Given the following user
      | login     | name       |
      | joaosilva | Joao Silva |
    And the following community
      | identifier  | name         |
      | mycommunity | My Community |
    And the following blocks
      | owner       | type                |
      | mycommunity | AverageRatingBlock  |
      | mycommunity | OrganizationRatingsBlock  |
    And the environment domain is "localhost"
    And I am logged in as "joaosilva"

  @selenium
  Scenario: display rate button inside average block
    Given I am on mycommunity's homepage
    Then I should see "Rate this Community" within ".average-rating-block"
    And I should see "Be the first to rate" within ".average-rating-block"

  @selenium
  Scenario: display rate button inside communities ratings block
    Given I am on mycommunity's homepage
    Then I should see "Rate Community" within ".make-report-block"
