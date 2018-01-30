Feature:
  As a user
  I want to add label for comments

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
  Given I am logged in as admin
  And I am on the environment control panel

  @selenium
  Scenario: dont display labels if admin did not configure status
    Given I follow "Plugins"
    And I check "Comment Classification"
    And I follow "Save changes"
    And "Maria Silva" is a member of "Sample Community"
    And "Joao Silva" is admin of "Sample Community"
    And I am logged in as "joaosilva"
    And I am on article "Article to comment"
    And I follow "Send"
    Then I should not see "Label" within "#page-comment-form"

  @selenium
  Scenario: admin configure labels
    Given I follow "Plugins"
    And I check "Comment Classification"
    And I follow "Save changes"
    And "Maria Silva" is a member of "Sample Community"
    And "Joao Silva" is admin of "Sample Community"
    And I am logged in as "admin_user"
    And I am on the environment control panel
    And I follow "Plugins"
    And I follow "Configuration"
    And I follow "Manage Labels"
    And I should see "no label registered yet" within "#comment-classification-labels"
    And I follow "Add a new label"
    And I fill in "Name" with "Question"
    And I check "Enable this label"
    And I follow "Save"
    Then I should see "Question" within "#comment-classification-labels"

  @selenium
  Scenario: save label for comment
    Given I follow "Plugins"
    And I check "Comment Classification"
    And I follow "Save changes"
    And "Maria Silva" is a member of "Sample Community"
    And "Joao Silva" is admin of "Sample Community"
    And I am logged in as "joaosilva"
    And the following labels
      | owner       | name     | enabled |
      | environment | Addition | true    |
    And I go to article "Article to comment"
    And I fill in "Leave your comment" with "Hey ho, let's go!"
    And I select "Addition" from "comment_label_id"
    And I follow "Send"
    Then I should see "Hey ho, let's go!" within ".comment-text"

  @selenium
  Scenario: users without permission should not edit the labels
    Given I follow "Plugins"
    And I check "Comment Classification"
    And I follow "Save changes"
    And "Maria Silva" is a member of "Sample Community"
    And "Joao Silva" is admin of "Sample Community"
    And I am logged in as "joaosilva"
    And the following labels
      | owner       | name     | enabled |
      | environment | Addition | true    |
    And I go to article "Article to comment"
    And I fill in "Leave your comment" with "Hey ho, let's go!"
    And I follow "Send"
    And I should see "Addition" within "#comment_label_id"
    And I am not logged in
    And I am on article "Article to comment"
    And I fill in "Leave your comment" with "Hey ho, let's go!"
    And I follow "Send"
    Then I should not see "#comment_label_id" within "#page-comment-form"
