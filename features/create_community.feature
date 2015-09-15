Feature: create community
  As a noosfero user
  I want to create a community
  In order to interact with other people

  Background:
    Given the following users
      | login | name |
      | joaosilva | Joao Silva |

  Scenario: a user creates a community
    Given I am logged in as "joaosilva"
    And feature "admin_must_approve_new_communities" is disabled on environment
    And I go to joaosilva's control panel
    And I follow "Manage my groups"
    When I follow "Create a new community"
    And I fill in "Name" with "Fancy community"
    And I press "Create"
    Then I should see "Fancy community"
    And I should see "Fancy community"'s creation date

  Scenario: a user creates a community when environment moderates it
    Given I am logged in as "joaosilva"
    And feature "admin_must_approve_new_communities" is enabled on environment
    And I go to joaosilva's control panel
    And I follow "Manage my groups"
    And I follow "Create a new community"
    And I fill in "Name" with "Community for moderation"
    And I press "Create"
    Then I should not see "Community for moderation"

  Scenario: a user tries to create a community without a name
    Given I am logged in as "joaosilva"
    And feature "admin_must_approve_new_communities" is disabled on environment
    And I go to joaosilva's control panel
    And I follow "Manage my groups"
    When I follow "Create a new community"
    And I press "Create"
    Then I should see "Creating new community"

  Scenario: environment admin receive a task when a user creates a community
    Given I am logged in as "joaosilva"
    And feature "admin_must_approve_new_communities" is enabled on environment
    Given "joaosilva" creates the community "Community for approval"
    Given I am logged in as admin
    And I go to admin_user's control panel
    Then I should see "Joao Silva wants to create community Community for approval"

  Scenario: environment admin accepts new community task
    Given I am logged in as "joaosilva"
    And feature "admin_must_approve_new_communities" is enabled on environment
    Given "joaosilva" creates the community "Community for approval"
    Given I am logged in as admin
    And I go to admin_user's control panel
    And I follow "Process requests"
    And I should see "Joao Silva wants to create community Community for approval"
    And I choose "Accept"
    When I press "Apply!"
    Then I should not see "Joao Silva wants to create community Community for approval"
    And I go to joaosilva's control panel
    And I follow "Manage my groups"
    Then I should see "Community for approval"

  Scenario: environment admin rejects new community task
    Given I am logged in as "joaosilva"
    And feature "admin_must_approve_new_communities" is enabled on environment
    Given "joaosilva" creates the community "Community for approval"
    Given I am logged in as admin
    And I go to admin_user's control panel
    And I follow "Process requests"
    And I should see "Joao Silva wants to create community Community for approval"
    And I choose "Reject"
    When I press "Apply!"
    Then I should not see "Joao Silva wants to create community Community for approval"
    And I go to joaosilva's control panel
    And I follow "Manage my groups"
    Then I should not see "Community for approval"

  Scenario: new community is listed after approval
    Given I am logged in as admin
    And feature "admin_must_approve_new_communities" is enabled on environment
    Given "admin_user" creates the community "Community for approval"
    And I approve community "Community for approval"
    And I go to admin_user's control panel
    And I follow "Manage my groups"
    Then I should see "Community for approval"

  Scenario: new community is not listed after rejection
    Given I am logged in as admin
    And feature "admin_must_approve_new_communities" is enabled on environment
    Given "admin_user" creates the community "Community for approval"
    And I reject community "Community for approval"
    And I go to admin_user's control panel
    And I follow "Manage my groups"
    Then I should not see "Community for approval"

