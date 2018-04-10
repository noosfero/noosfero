Feature:
  As a user
  I want to add status for comments

Background:
  Given the following users
    | login      |  name       |
    | joaosilva  | Joao Silva  |
    | mariasilva | Maria Silva |
  And the following communities
    | identifier       | name             |
    | sample-community | Sample Community |
  And the following articles
    | owner            | name               | body       |
    | sample-community | Article to comment | First post |
    And the following comments
      | article            | author     | body        |
      | Article to comment | mariasilva | great post! |
  And "CommentClassification" plugin is enabled
  And "Maria Silva" is a member of "Sample Community"
  And "Joao Silva" is admin of "Sample Community"
  And I am logged in as "joaosilva"

@selenium
  Scenario: dont display to add status if not an organization
    Given I am logged in as admin
    Given I am on the environment control panel
    Given I follow "Plugins"
    Given I check "Comment Classification"
    Then I follow "Save changes"
    And I should see "Plugins updated successfully."
    And "Maria Silva" is a member of "Sample Community"
    And "Joao Silva" is admin of "Sample Community"
    Then I am logged in as "joaosilva"
    Given the following articles
      | owner     | name                        | body       |
      | joaosilva | Article on a person profile | First post |
    And the following comments
      | article                     | author     | body        |
      | Article on a person profile | mariasilva | great post! |
    Given I am on article "Article on a person profile"
    Then I should see "great post!" within ".comment-content"
    And I should not see "Status" within ".comment-content"

@selenium
  Scenario: dont display to add status if admin did not configure status
    Given I am logged in as admin
    Given I am on the environment control panel
    Given I follow "Plugins"
    Given I check "Comment Classification"
    Then I follow "Save changes"
    And I should see "Plugins updated successfully."
    And "Maria Silva" is a member of "Sample Community"
    And "Joao Silva" is admin of "Sample Community"
    Then I am logged in as "joaosilva"
    Given I am on article "Article to comment"
    Then I should see "great post!" within ".comment-content"
    And I should not see "Status" within ".comment-content"

  @selenium
  Scenario: admin configure status
    Given I am not logged in
    And I am logged in as admin
    And I am on the environment control panel
    And I follow "Plugins"
    And I follow "Configuration"
    And I follow "Manage Status"
    Then I should see "no status registered yet" within "#comment-classification-status"
    When I follow "Add a new status"
    And I fill in "Name" with "Merged"
    And I check "Enable this status"
    And I follow "Save"
    Then I should see "Merged" within "#comment-classification-status"

@selenium
  Scenario: save status for comment
    Given I am logged in as admin
    Given I am on the environment control panel
    Given I follow "Plugins"
    Given I check "Comment Classification"
    Then I follow "Save changes"
    And I should see "Plugins updated successfully."
    And "Maria Silva" is a member of "Sample Community"
    And "Joao Silva" is admin of "Sample Community"
    Then I am logged in as "joaosilva"
    Given the following status
      | owner       | name   | enabled |
      | environment | Merged | true    |
    And I go to article "Article to comment"
    And I follow "Status"
    Then I select "Merged" from "status_status_id"
    And I follow "Save"
    Then I should see "added the status Merged" within "#comment-classification-status-list"

@selenium
  Scenario: dont display to add status if user not allowed
    Given I am logged in as admin
    Given I am on the environment control panel
    Given I follow "Plugins"
    Given I check "Comment Classification"
    Then I follow "Save changes"
    And I should see "Plugins updated successfully."
    And "Maria Silva" is a member of "Sample Community"
    And "Joao Silva" is admin of "Sample Community"
    Then I am logged in as "joaosilva"
    And I am logged in as "mariasilva"
    When I go to article "Article to comment"
    Then I should see "great post!" within ".comment-content"
    And I should not see "Status" within ".comment-content"
