Feature: vote_once_disable_cooldown
  As a admin
  I want to disable the cooldown time when vote once is enabled
  Making it clearly that there is no cooldown when vote once is enabled

  Background:
    Given plugin "OrganizationRatings" is enabled on environment
    And I am logged in as admin
    And I go to /admin/plugins
    And I check "Organization Ratings"
    And I press "Save changes"

  @selenium
  Scenario: disable or enable the cooldown field when vote on is checked or unchecked
    Given I follow "Administration"
    And I follow "Plugins"
    And I follow "Configuration"
    And the field "#organization_ratings_config_cooldown" should be enabled
    And I check "Vote once"
    And the field "#organization_ratings_config_cooldown" should be disabled
    And I uncheck "Vote once"
    Then the field "#organization_ratings_config_cooldown" should be enabled

