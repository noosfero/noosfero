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
  And "CommentClassification" plugin is enabled
  And "Maria Silva" is a member of "Sample Community"
  And "Joao Silva" is admin of "Sample Community"

  @selenium
  Scenario: dont display labels if admin did not configure status
    Given I am logged in as "joaosilva"
    And I am on article "Article to comment"
    Then I should not see "Label" within "#page-comment-form"

  @selenium
  Scenario: admin configure labels
    Given I am logged in as admin
    And I am on the environment control panel
    And I follow "Plugins"
    And I follow "Configuration"
    And I follow "Manage Labels"
    And I should see "no label registered yet" within "#comment-classification-labels"
    And I follow "Add a new label"
    And I fill in "Name" with "Question"
    And I check "Enable this label"
    When I follow "Save"
    Then I should see "Question" within "#comment-classification-labels"

  @selenium
  Scenario: save label for comment
    Given the following labels
      | name     | enabled |
      | Addition | true    |
    And I am logged in as "joaosilva"
    And I go to article "Article to comment"
    And I fill in "Leave your comment" with "Hey ho, let's go!"
    Then I select "Addition" from "comment_label_id"
    And I press "Send"
    Then I should see "Addition" within ".comment-classification-options"

  @selenium
  Scenario: users without permission should not edit the labels
    Given the following labels
      | owner       | name     | enabled |
      | environment | Addition | true    |
    And I am logged in as "joaosilva"
    And I go to article "Article to comment"
    Then I should see "Label" within "#page-comment-form"
    And I should see "Addition" within "#comment_label_id"
    When I am not logged in
    And I am on article "Article to comment"
    Then I should not see "Label" within "#page-comment-form"

