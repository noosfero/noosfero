Feature: domain for profile
  As a user
  I want access a profile by its own domain

  Background:
    Given the following user
      | login     | name       |
      | joaosilva | Joao Silva |
    And the following communities
      | identifier       | name             | domain    |
      | sample-community | Sample Community | localhost |
    And the following blocks
      | owner            | type              |
      | sample-community | ProfileImageBlock |
      | sample-community | ProfileInfoBlock  |
    And the environment domain is "127.0.0.1"
    And "Joao Silva" is admin of "Sample Community"

  @selenium
  Scenario: access profile control panel through profile blocks
    Given I am logged in as "joaosilva"
    When I visit "/" and wait
    And I follow "Control panel" within "div.profile-info-block" and wait
    Then I should see "Sample Community" within "span.control-panel-title"
    When I visit "/" and wait
    And I follow "Control panel" within "div.profile-image-block" and wait
    Then I should see "Sample Community" within "span.control-panel-title"

  @selenium
  Scenario: access user control panel
    Given I am logged in as "joaosilva"
    When I visit "/" and wait
    And I follow "joaosilva" and wait
    And I follow "Login"
    And I fill in "joaosilva" for "Username"
    And I fill in "123456" for "Password"
    And I press "Log in" and wait
    And I follow "Control panel" within "div#user" and wait
    Then I should see "Joao Silva" within "span.control-panel-title"

  @selenium
  Scenario: access user page
    Given I am logged in as "joaosilva"
    When I visit "/" and wait
    And I follow "joaosilva" and wait
    Then The page title should contain "Joao Silva"

  @selenium
  Scenario: access community by domain
    When I go to the homepage
    Then The page title should contain "Sample Community"

  @selenium
  Scenario: Go to profile homepage after clicking on home button on not found page
    Given I am on the homepage
    When I go to /something-that-does-not-exist
    And I follow "Go to the home page"
    Then the page title should be "Sample Community - Colivre.net"

  @selenium
  Scenario: Go to environment homepage after clicking on home button on not found page
    Given I am on the homepage
    And I click on the logo
    When I open /something-that-does-not-exist
    And I follow "Go to the home page"
    Then the page title should be "Colivre.net"

  @selenium
  Scenario: Compose link to administration with environment domain
    Given I am logged in as "joaosilva"
    When I visit "/" and wait
    Then I should see "Administration" linking to "http://127.0.0.1:3001/admin"
