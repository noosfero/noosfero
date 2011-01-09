Feature: comment
  As a visitor
  I want to reply comments

  Background:
    Given the following users
      | login   |
      | booking |
    And the following articles
      | owner   | name               |
      | booking | article to comment |
      | booking | another article    |
		And the following comments
		  | article            | author  | title        | body                        |
			| article to comment | booking | root comment | this comment is not a reply |
			| another article    | booking | some comment | this is my very own comment |

	Scenario: not post a comment without javascript
    Given I am on /booking/article-to-comment
    When I follow "Reply" within ".comment-balloon"
    Then I should not see "Enter your comment" within "div.comment-balloon"

  Scenario: not show any reply form by default
    When I go to /booking/article-to-comment
    Then I should not see "Enter your comment" within "div.comment-balloon"
    And I should see "Reply" within "div.comment-balloon"

  @selenium
  Scenario: show error messages when make a blank comment reply
    Given I am logged in as "booking"
    And I go to /booking/article-to-comment
    And I follow "Reply" within ".comment-balloon"
    When I press "Post comment" within ".comment-balloon"
    Then I should see "Title can't be blank" within "div.comment_reply"
    And I should see "Body can't be blank" within "div.comment_reply"

  @selenium
  Scenario: not show any reply form by default
    When I go to /booking/article-to-comment
    Then I should not see "Enter your comment" within "div.comment-balloon"
    And I should see "Reply" within "div.comment-balloon"

	@selenium
  Scenario: render reply form
    Given I am on /booking/article-to-comment
    When I follow "Reply" within ".comment-balloon"
    Then I should see "Enter your comment" within "div.comment_reply.opened"

	@selenium
  Scenario: cancel comment reply
    Given I am on /booking/article-to-comment
    When I follow "Reply" within ".comment-balloon"
		And I follow "Cancel" within ".comment-balloon"
    Then I should see "Enter your comment" within "div.comment_reply.closed"

	@selenium
  Scenario: not render same reply form twice
    Given I am on /booking/article-to-comment
    When I follow "Reply" within ".comment-balloon"
		And I follow "Cancel" within ".comment-balloon"
    And I follow "Reply" within ".comment-balloon"
    Then there should be 1 "comment_form" within "comment_reply"
    And I should see "Enter your comment" within "div.comment_reply.opened"

	@selenium
  Scenario: reply a comment
    Given I am logged in as "booking"
    And I go to /booking/another-article
    And I follow "Reply" within ".comment-balloon"
    And I fill in "Title" within "comment-balloon" with "Hey ho, let's go!"
    And I fill in "Enter your comment" within "comment-balloon" with "Hey ho, let's go!"
    When I press "Post comment" within ".comment-balloon"
    Then I should see "Hey ho, let's go" within "ul.comment-replies"
    And there should be 1 "comment-replies" within "article-comment"

  @selenium
  Scenario: redirect to right place after reply a picture comment
    Given the following files
      | owner   | file      | mime      |
      | booking | rails.png | image/png |
    And the following comment
		  | article   | author  | title        | body                        |
			| rails.png | booking | root comment | this comment is not a reply |
		Given I am logged in as "booking"
    And I go to /booking/rails.png?view=true
    And I follow "Reply" within ".comment-balloon"
    And I fill in "Title" within "comment-balloon" with "Hey ho, let's go!"
    And I fill in "Enter your comment" within "comment-balloon" with "Hey ho, let's go!"
    When I press "Post comment" within ".comment-balloon"
    Then I should be exactly on /booking/rails.png?view=true
