Feature: edit_image
  As a noosfero user
  I want to upload images and assigns a link to each image

  Background:
    Given I am on the homepage
    And the following users
      | login   | name   |
      | morgoth | Melkor |
    And I am logged in as "morgoth"

  Scenario: edit external link when edit image
    Given the following files
      | owner   | file      | mime      |
      | morgoth | rails.png | image/png |
    When I go to edit "rails.png" by morgoth
    Then I should see "External link"

  Scenario: dont offer to edit external link if no image
    Given the following files
      | owner   | file     | mime       |
      | morgoth | test_another.txt | text/plain |
    When I go to edit "test_another.txt" by morgoth
    Then I should not see "External link"

  Scenario: display tag list field when editing file
    Given the following files
      | owner   | file      | mime      |
      | morgoth | rails.png | image/png |
    When I go to edit "rails.png" by morgoth
    Then I should see "Tag list"
