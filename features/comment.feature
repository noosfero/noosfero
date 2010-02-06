Feature: comment
  As a visitor
  I want to post comments

  Background:
    Given the following users
      | login   |
      | booking |
    And the following articles
      | owner   | name               |
      | booking | article to comment |

  Scenario: not post a comment without javascript
    Given I am on /booking/article-to-comment
    And I fill in "Name" with "Joey Ramone"
    And I fill in "e-Mail" with "joey@ramones.com"
    And I fill in "Title" with "Hey ho, let's go!"
    And I fill in "Enter your comment" with "Hey ho, let's go!"
    When I press "Post comment"
    Then I should not see "Hey ho, let's go"

  @selenium
  Scenario: post a comment while not authenticated
    Given I am on /booking/article-to-comment
    And I fill in "Name" with "Joey Ramone"
    And I fill in "e-Mail" with "joey@ramones.com"
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
    Given I am logged in as "booking"
    And the following files
      | owner   | file      | mime      |
      | booking | rails.png | image/png |
    And I am on /booking/rails.png?view=true
    And I fill in "Title" with "Hey ho, let's go!"
    And I fill in "Enter your comment" with "Hey ho, let's go!"
    When I press "Post comment"
    And I wait 2 seconds
    Then I should be exactly on /booking/rails.png?view=true

  @selenium
  Scenario: show error messages when make a blank comment
    Given I am logged in as "booking"
    And I am on /booking/article-to-comment
    When I press "Post comment"
    And I wait 2 seconds
    Then I should see "Title can't be blank"
    And I should see "Body can't be blank"
