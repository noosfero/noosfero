Feature: Create a new Discussion Article
  As a noosfero user
  I want to create a discusssion article

  Background:
    Given Noosfero is configured to use English as default
    Given plugin CommentParagraph is enabled on environment
    Given I am on the homepage
    And the following users
      | login     | name       |
      | joaosilva | Joao Silva |
    And I am logged in as "joaosilva"

  @selenium
  Scenario: discussion article should save content body
  Given I am on joaosilva's control panel
  And I follow "Manage Content"
  And I follow "New content"
  When I follow "Comments Discussion"
  And I fill in "Title" with "My discussion"
  And I fill in tinyMCE "article_body" with "My discussion body!!!"
  And I press "Save"
  Then I should see "My discussion body!!!"
