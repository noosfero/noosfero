Feature: video player
  As a noosfero visitor
  I want to view a video page and play it

  Background:
    Given plugin Html5Video is enabled on environment
    And the following users
      | login     | name       |
      | joaosilva | Joao Silva |
    And the following uploaded files
      | owner     | filename                | mime       |
      | joaosilva | ../videos/old-movie.mpg | video/mpeg |
    And there are no pending jobs
    And all videos are processed

  @selenium
  Scenario: controls must work
    Given I am on /joaosilva/old-movie?view=true
    And I move the cursor over ".video-player .video-box"
    And I click ".video-player .video-box .zoom"
    Then The page should contain only 2 ".video-player .quality li.ui-button"
    And the element ".video-player" has class "zoom-in"
