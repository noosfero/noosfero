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
    Given I am on /joaosilva/old-movie.mpg?view=true
    Then The page should contain only 2 ".video-player .quality li.ui-button"
    #FIXME
    #When I click ".video-player .video-box .zoom"
    #Then the element ".video-player" has class "zoom-in"
