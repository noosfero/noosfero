Feature: gallery_navigation
  As a noosfero user
  I want to navigate over image gallery

  Background:
    Given the following users
      | login       |
      | marciopunk  |
    And the following galleries
      | owner      | name          |
      | marciopunk | my-gallery    |
      | marciopunk | other-gallery |
    And the following files
      | owner      | file          | mime       | parent        |
      | marciopunk | rails.png     | image/png  | my-gallery    |
      | marciopunk | rails.png     | image/png  | other-gallery |
      | marciopunk | other-pic.jpg | image/jpeg | my-gallery    |

  Scenario: provide link to go to next image
    Given I am on /marciopunk/my-gallery/other-pic.jpg?view=true
    Then I should see "Next »"

  @selenium
  Scenario: view next image when follow next link
    Given I am on /marciopunk/my-gallery/other-pic.jpg?view=true
    When I follow "Next »" and wait
    Then I should see "rails.png" within ".title"

  Scenario: not link to next when in last image
    When I am on /marciopunk/my-gallery/rails.png?view=true
    Then I should see "« Previous" within ".gallery-navigation a"
    And I should not see "Next »" within ".gallery-navigation a"

  Scenario: provide link to go to previous image
    Given I am on /marciopunk/my-gallery/other-pic.jpg?view=true
    Then I should see "« Previous"

  @selenium
  Scenario: view previous image when follow previous link
    Given I am on /marciopunk/my-gallery/rails.png?view=true
    When I follow "« Previous" and wait
    Then I should see "other-pic.jpg" within ".title"

  Scenario: not link to previous when in first image
    When I am on /marciopunk/my-gallery/other-pic.jpg?view=true
    Then I should see "Next »" within ".gallery-navigation a"
    And I should not see "« Previous" within ".gallery-navigation a"

  Scenario: display number of current and total of images
    Given I am on /marciopunk/my-gallery/other-pic.jpg?view=true
    Then I should see "image 1 of 2" within ".gallery-navigation"

  Scenario: increment current number when follow next
    Given I am on /marciopunk/my-gallery/other-pic.jpg?view=true
    Then I should see "image 1 of 2" within ".gallery-navigation"
    When I follow "Next »"
    Then I should see "image 2 of 2" within ".gallery-navigation"

  Scenario: decrement current number when follow next
    Given I am on /marciopunk/my-gallery/rails.png?view=true
    Then I should see "image 2 of 2" within ".gallery-navigation"
    When I follow "« Previous"
    Then I should see "image 1 of 2" within ".gallery-navigation"

  Scenario: provide button to go back to gallery
    Given I am on /marciopunk/my-gallery/rails.png?view=true
    Then I should see "Go back to my-gallery"
    When I follow "Go back to my-gallery"
    Then I should be on /marciopunk/my-gallery

  @selenium
  Scenario: image title in window title
    Given I am logged in as "marciopunk"
    When I visit "/marciopunk/other-gallery/rails.png?view=true" and wait
    And I follow "Edit" and wait
    And I fill in "Title" with "Rails is cool"
    And I press "Save" and wait
    Then The page title should contain "Rails is cool"
