Feature: edit_image
  As a noosfero user
  I want to upload images and assigns a link to each image

  Scenario: edit external link when edit image
    Given I am on the homepage
    And the following users
      | login   | name   |
      | morgoth | Melkor |
    And the following files
      | owner   | file      | mime      |
      | morgoth | rails.png | image/png |
    And I am logged in as "morgoth"
    When I go to edit "rails.png" by morgoth
    Then I should see "External link"

  Scenario: dont offer to edit external link if no image
    Given I am on the homepage
    And the following users
      | login   | name   |
      | morgoth | Melkor |
    And the following files
      | owner   | file     | mime       |
      | morgoth | test.txt | text/plain |
    And I am logged in as "morgoth"
    When I go to edit "test.txt" by morgoth
    Then I should not see "External link"
