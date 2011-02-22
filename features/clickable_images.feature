Feature: clickable images
  As a visitor
  I want to zoom in article images

  Background:
    Given feature "show_zoom_button_on_article_images" is enabled on environment
    And the following users
      | login   |
      | booking |

  @selenium
  Scenario: show link if image is scaled
    Given the following article with image
      | owner   | name  | image     | dimensions |
      | booking | small | rails.png | 20x20      |
    When I go to /booking/small
    Then I should see "Zoom in"

  @selenium
  Scenario: not show link if image is not scaled
    Given the following article with image
      | owner   | name | image     | dimensions |
      | booking | real | rails.png | 50x64      |
    When I go to /booking/real
    Then I should not see "Zoom in"

  @selenium
  Scenario: not show link if image does not have dimensions set
    Given the following article with image
      | owner   | name    | image     |
      | booking | not set | rails.png |
    When I go to /booking/not-set
    Then I should not see "Zoom in"

  @selenium
  Scenario: copy style from image
    Given the following article with image
      | owner   | name       | image     | style        | dimensions |
      | booking | with style | rails.png | float: right | 25x32      |
    When I go to /booking/with-style
    Then "zoomable-image" should be right aligned

  @selenium
  Scenario: zoom image
    Given the following article with image
      | owner   | name | image     | dimensions |
      | booking | zoom | rails.png | 25x32      |
    When I go to /booking/zoom
    And I follow "Zoom in"
    Then the "#fancybox-wrap" should be visible
