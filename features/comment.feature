Feature: comment
  As a visitor
  I want to post comments

  Background:
    Given the following users
      | login   |
      | booking |
    And the following articles
      | owner   | name                 |
      | booking | article to comment   |
      | booking | article with comment |
    And the following comments
      | article              | author  | title | body         |
      | article with comment | booking | hi    | how are you? |
      | article with comment | booking | hello | i am fine    |

  Scenario: not post a comment without javascript
    Given I am on /booking/article-to-comment
    And I fill in "Name" with "Joey Ramone"
    And I fill in "e-mail" with "joey@ramones.com"
    And I fill in "Title" with "Hey ho, let's go!"
    And I fill in "Enter your comment" with "Hey ho, let's go!"
    When I press "Post comment"
    Then I should not see "Hey ho, let's go"

  @selenium
  Scenario: post a comment while not authenticated
    Given I am on /booking/article-to-comment
    And I fill in "Name" with "Joey Ramone"
    And I fill in "e-mail" with "joey@ramones.com"
    And I fill in "Title" with "Hey ho, let's go!"
    And I fill in "Enter your comment" with "Hey ho, let's go!"
    When I press "Post comment"
    Then I should see "Hey ho, let's go"

  @selenium
  Scenario: post comment while authenticated
    Given I am logged in as "booking"
    And I am on /booking/article-to-comment
    And I fill in "Title" with "Hey ho, let's go!"
    And I fill in "Enter your comment" with "Hey ho, let's go!"
    When I press "Post comment"
    Then I should see "Hey ho, let's go"

  @selenium
  Scenario: redirect to right place after comment a picture
    Given the following files
      | owner   | file      | mime      |
      | booking | rails.png | image/png |
    Given I am logged in as "booking"
    And I am on /booking/rails.png?view=true
    And I fill in "Title" with "Hey ho, let's go!"
    And I fill in "Enter your comment" with "Hey ho, let's go!"
    When I press "Post comment"
    Then I should be exactly on /booking/rails.png?view=true

  @selenium
  Scenario: show error messages when make a blank comment
    Given I am logged in as "booking"
    And I am on /booking/article-to-comment
    When I press "Post comment"
    Then I should see "Title can't be blank"
    And I should see "Body can't be blank"

  @selenium
  Scenario: disable post comment button
    Given I am on /booking/article-to-comment
    And I fill in "Name" with "Joey Ramone"
    And I fill in "e-mail" with "joey@ramones.com"
    And I fill in "Title" with "Hey ho, let's go!"
    And I fill in "Enter your comment" with "Hey ho, let's go!"
    When I press "Post comment"
    Then the "value.Post comment" button should not be enabled
    And I should see "Hey ho, let's go"

  @selenium
  Scenario: render comment form and go to bottom
    Given I am on /booking/article-with-comment
    When I follow "Post a comment" within ".post-comment-button"
    Then I should see "Enter your comment" within "div#page-comment-form div.post_comment_box.opened"
    And I should be exactly on /booking/article-with-comment
    And I should be moved to anchor "comment_form"

  @selenium
  Scenario: keep comments field filled while trying to do a comment
    Given I am on /booking/article-with-comment
    And I fill in "Name" with "Joey Ramone"
    When I press "Post comment"
    Then the "Name" field should contain "Joey Ramone"
    And I should see "errors prohibited"
