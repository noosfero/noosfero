Feature: domain for profile

  As a user
  I want access a profile by its own domain

  Background:
    Given the following user
      | login     | name       |
      | joaosilva | Joao Silva |
    And the following communities
      | identifier       | name             | domain    |
      | sample-community | Sample Community | 127.0.0.1 |
    And the following blocks
      | owner            | type              |
      | joaosilva        | ProfileInfoBlock  |
    And the environment domain is "localhost"
    And "Joao Silva" is environment admin
    And "Joao Silva" is admin of "Sample Community"

  Scenario: access profile control panel through profile blocks
    Given I am logged in as "joaosilva"
    When I go to joaosilva's homepage
    And I follow "Control panel" within ".profile-image-block"
    Then I should see "Joao Silva" within "span.control-panel-title"

  Scenario: can't see profile if domain is different
    Given I am logged in as "joaosilva"
    When I follow "Profile"
    And I go to sample-community's homepage
    Then I should not see "Sample Community" within any "h1"

  Scenario: access user page
    Given I am logged in as "joaosilva"
    When I follow "Profile"
    Then I should be on joaosilva's profile
    And I should see "Joao Silva" within any "h1"
    And the page title should be "Joao Silva"

  Scenario: access community by domain
    Given I go to the search communities page
    When I follow "Sample Community" within ".search-profile-item"
    Then the page title should be "Sample Community"

  # This test is not working because the community domain isn't at all different
  # from the environment (localhost / 127.0.0.1)
  @fixme
  Scenario: Go to profile homepage after clicking on home button on not found page
    Given I am on sample-community's homepage
    When I go to /something-that-does-not-exist
    And I follow "Go to the home page"
    Then the page title should be "Sample Community"

  Scenario: Go to environment homepage after clicking on home button on not found page
    Given I am on the homepage
    When I go to /something-that-does-not-exist
    And I follow "Go to the home page"
    Then I should be on the homepage
    And the page title should be "Colivre.net"
