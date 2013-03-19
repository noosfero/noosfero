Feature: delete profile
  As a noosfero user
  I want to delete my profile
  In order to leave the network

  Background:
    Given the following users
      | login | name |
      | joaosilva | Joao Silva |
      | mariasilva | Maria Silva |
    And the following community
      | identifier | name |
      | sample-community | Sample Community |
    And "Maria Silva" is a member of "Sample Community"

  @selenium
  Scenario: deleting profile
    Given I am logged in as "joaosilva"
    And I am on joaosilva's control panel
    And I follow "Edit Profile"
    And I follow "Delete profile"
    Then I should see "Are you sure you want to delete this profile?"
    When I follow "Yes, I am sure"
    Then I should be on the homepage
    When I go to /joaosilva
    Then I should see "There is no such page"

  Scenario: deleting other profile
    Given I am logged in as "mariasilva"
    And I go to /myprofile/joaosilva/profile_editor/destroy_profile
    Then I should see "Access denied"

  Scenario: giving up of deleting profile
    Given I am logged in as "joaosilva"
    And I am on joaosilva's control panel
    And I follow "Edit Profile"
    And I follow "Delete profile"
    Then I should see "Are you sure you want to delete this profile?"
    When I follow "No, I gave up"
    Then I should be on joaosilva's profile

  Scenario: community admin can see link to delete profile
    Given "Joao Silva" is admin of "Sample Community"
    And I am logged in as "joaosilva"
    And I am on sample-community's control panel
    When I follow "Community Info and settings"
    Then I should see "Delete profile"

  @selenium
  Scenario: community admin deletes the community
    Given "Joao Silva" is admin of "Sample Community"
    And I am logged in as "joaosilva"
    And I am on sample-community's control panel
    And I follow "Community Info and settings"
    And I follow "Delete profile"
    Then I should see "Are you sure you want to delete this profile?"
    When I follow "Yes, I am sure"
    Then I should be on the homepage
    When I go to /sample-community
    Then I should see "There is no such page"

  Scenario: community regular member tries to delete the community
    Given "Joao Silva" is a member of "Sample Community"
    And I am logged in as "joaosilva"
    And I go to /myprofile/sample-community/profile_editor/destroy_profile
    Then I should see "Access denied"

  Scenario: enterprise admin can see link to delete enterprise
    Given the following enterprise
      | identifier | name |
      | sample-enterprise | Sample Enterprise |
    And "Joao Silva" is admin of "Sample Enterprise"
    And I am logged in as "joaosilva"
    And I am on sample-enterprise's control panel
    When I follow "Enterprise Info and settings"
    Then I should see "Delete profile"

  @selenium
  Scenario: enterprise admin deletes the enterprise
    Given the following enterprise
      | identifier | name |
      | sample-enterprise | Sample Enterprise |
    And "Joao Silva" is admin of "Sample Enterprise"
    And I am logged in as "joaosilva"
    And I am on sample-enterprise's control panel
    When I follow "Enterprise Info and settings"
    And I follow "Delete profile"
    Then I should see "Are you sure you want to delete this profile?"
    When I follow "Yes, I am sure"
    Then I should be on the homepage
    When I go to /sample-enterprise
    Then I should see "There is no such page"

  Scenario: enterprise regular member tries to delete the enterprise
    Given the following enterprise
      | identifier | name |
      | sample-enterprise | Sample Enterprise |
    And "Maria Silva" is a member of "Sample Enterprise"
    And "Joao Silva" is a member of "Sample Enterprise"
    And I am logged in as "joaosilva"
    And I go to /myprofile/sample-enterprise/profile_editor/destroy_profile
    Then I should see "Access denied"

  @selenium
  Scenario: environment admin deletes profile
    Given I am logged in as admin
    And I am on joaosilva's control panel
    And I follow "Edit Profile"
    And I follow "Delete profile"
    Then I should see "Are you sure you want to delete this profile?"
    When I follow "Yes, I am sure"
    Then I should be on the homepage
    When I go to /joaosilva
    Then I should see "There is no such page"
