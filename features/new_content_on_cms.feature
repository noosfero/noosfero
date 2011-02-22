Feature: create content on cms
  As a noosfero user
  I want to create articles and upload files

  Background:
    Given the following users
      | login     | name       |
      | joaosilva | Joao Silva |
    And I am logged in as "joaosilva"
    And I am on Joao Silva's cms

  Scenario: open page to select type of content
    Given I follow "New Content"
    Then I should see "Choose the type of content"

  Scenario: list all content types
    Given I follow "New content"
    Then I should see "Text article with visual editor"
     And I should see "Text article with Textile markup"
     And I should see "Folder"
     And I should see "Blog"
     And I should see "Uploaded file"
     And I should see "Event"

  Scenario: create a folder
    Given I follow "New content"
    When I follow "Folder"
    And I fill in "Title" with "My Folder"
    And I press "Save"
    And I go to Joao Silva's cms
    Then I should see "My Folder"

  Scenario: create a tiny_mce article
    Given I follow "New content"
    When I follow "Text article with visual editor"
    And I fill in "Title" with "My tiny_mce article"
    And I press "Save"
    And I go to Joao Silva's cms
    Then I should see "My tiny_mce article"

  Scenario: create a textile article
    Given I follow "New content"
    When I follow "Text article with Textile markup"
    And I fill in "Title" with "My textile article"
    And I press "Save"
    And I go to Joao Silva's cms
    Then I should see "My textile article"

  Scenario: create a Blog
    Given I follow "New content"
    When I follow "Blog"
    And I fill in "Title" with "My blog"
    And I press "Save"
    And I go to Joao Silva's cms
    Then I should see "My blog"

  Scenario: create an event
    Given I follow "New content"
    When I follow "Event"
    And I fill in "Title" with "My event"
    And I press "Save"
    And I go to Joao Silva's cms
    Then I should see "My event"

  Scenario: redirect to upload files if choose UploadedFile
    Given I follow "New content"
    When I follow "Uploaded file"
    Then I should be on /myprofile/joaosilva/cms/upload_files
