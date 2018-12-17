Feature: senstive content
  As a user
  I want to create new contents
  according to the current context

  Background:
    Given I am on the homepage
    And the following users
      | login     | name       |
      | joaosilva | Joao Silva |
    And the following communities
      | identifier | name |
      | sample-community | Sample Community |
    And "Joao Silva" is admin of "Sample Community"
    And I am logged in as "joaosilva"

  # Scenario: create content with the user on the home page
  #   Given I go to the homepage
  #   And I follow "New Content"
  #   And I should see "You are publishing in profile of Joao Silva"
  #   And I follow "Text article"
  #   Then I should be on /myprofile/joaosilva/cms/new
  #
  # Scenario: create gallery from sensitive content button
  #   Given I go to the homepage
  #   And I follow "New Content"
  #   And I should see "You are publishing in profile of Joao Silva"
  #   And I follow "Gallery"
  #   Then I should be on /myprofile/joaosilva/cms/new
  #   And I should see an element "form.gallery"
  #
  # @selenium
  # Scenario: create blog from sensitive content button
  #   Given I go to the homepage
  #   And I follow "New Content"
  #   And I should see "You are publishing in profile of Joao Silva"
  #   And I follow "Blog"
  #   Then I should be on /myprofile/joaosilva/cms/new
  #   And I should see an element "form.blog"
  #
  # Scenario: create forum from sensitive content button
  #   Given I go to the homepage
  #   And I follow "New Content"
  #   And I should see "You are publishing in profile of Joao Silva"
  #   And I follow "Forum"
  #   Then I should be on /myprofile/joaosilva/cms/new
  #   And I should see an element "form.forum"
  #
  # Scenario: create folder from sensitive content button
  #   Given I go to the homepage
  #   And I follow "New Content"
  #   And I should see "You are publishing in profile of Joao Silva"
  #   And I follow "Folder"
  #   Then I should be on /myprofile/joaosilva/cms/new
  #   And I should see an element "form.folder"
  #
  # @selenium
  # Scenario: create event from sensitive content button
  #   Given I go to the homepage
  #   And I follow "New Content"
  #   And I should see "You are publishing in profile of Joao Silva"
  #   And I follow "Event"
  #   Then I should be on /myprofile/joaosilva/cms/new
  #   And I should see an element "form.event"
  #
  # Scenario: create uploaded file from sensitive content button
  #   Given I go to the homepage
  #   And I follow "New Content"
  #   And I should see "You are publishing in profile of Joao Silva"
  #   And I follow "Uploaded file"
  #   Then I should be on /myprofile/joaosilva/cms/upload_files
  #
  # Scenario: create rss feed from sensitive content button
  #   Given I go to the homepage
  #   And I follow "New Content"
  #   And I should see "You are publishing in profile of Joao Silva"
  #   And I follow "RSS Feed"
  #   Then I should be on /myprofile/joaosilva/cms/new
  #   And I should see an element "form.rss-feed"
  #
  # Scenario: show content options to generic context
  #   Given I go to the homepage
  #   And I follow "New Content"
  #   And I should see "You are publishing in profile of Joao Silva"
  #   And I should see "Text article" within ".article-types"
  #   And I should see "Event" within ".article-types"
  #   And I should see "Folder" within ".article-types"
  #   And I should see "Blog" within ".article-types"
  #   And I should see "Uploaded file" within ".article-types"
  #   And I should see "Gallery" within ".article-types"
  #   And I should see "Forum" within ".article-types"
  #   And I should see "RSS Feed" within ".article-types"
  #
  # Scenario: show content options to blog context
  #   Given I am on joaosilva's profile
  #   And I follow "Blog"
  #   And I follow "New Content"
  #   And I should see "You are publishing in Blog of Joao Silva"
  #   And I should see "Text article" within ".article-types"
  #   And I should see "Event" within ".article-types"
  #   And I should see "RSS Feed" within ".article-types"
  #   And I should not see "Folder" within ".article-types"
  #   And I should not see "Blog" within ".article-types"
  #   And I should not see "Uploaded file" within ".article-types"
  #   And I should not see "Gallery" within ".article-types"
  #   And I should not see "Forum" within ".article-types"
  #
  # Scenario: show content options to gallery context
  #   Given I am on joaosilva's profile
  #   And I follow "Image gallery"
  #   And I follow "New Content"
  #   And I should see "You are publishing in Gallery of Joao Silva"
  #   And I should see "Uploaded file" within ".article-types"
  #   And I should not see "Text article" within ".article-types"
  #   And I should not see "Event" within ".article-types"
  #   And I should not see "Folder" within ".article-types"
  #   And I should not see "Blog" within ".article-types"
  #   And I should not see "Gallery" within ".article-types"
  #   And I should not see "Forum" within ".article-types"
  #   And I should not see "RSS Feed" within ".article-types"
  #
  # @selenium
  # Scenario: show content options to folder context
  #   Given I am on joaosilva's control panel
  #   And I follow "New" within "#section-content"
  #   And I should see "Folder"
  #   And I follow "Folder"
  #   And I fill in "Title" with "My Folder"
  #   And I follow "Save"
  #   And I should be on /joaosilva/my-folder
  #   And I follow "New Content"
  #   And I should see "You are publishing in My Folder of Joao Silva"
  #   And I should see "Text article" within ".article-types"
  #   And I should see "Event" within ".article-types"
  #   And I should see "Folder" within ".article-types"
  #   And I should see "Uploaded file" within ".article-types"
  #   And I should not see "Blog" within ".article-types"
  #   And I should not see "Gallery" within ".article-types"
  #   And I should not see "Forum" within ".article-types"
  #   And I should not see "RSS Feed" within ".article-types"
  #
  # @selenium
  # Scenario: show content options to forum context
  #   Given I am on joaosilva's control panel
  #   And I follow "Manage" within "#section-content"
  #   And I follow "New content"
  #   And I follow "Forum"
  #   And I fill in "Title" with "My Forum"
  #   And I follow "Save"
  #   And I should be on /joaosilva/my-forum
  #   And I follow "New Content"
  #   And I should see "You are publishing in My Forum of Joao Silva"
  #   And I should see "Text article" within ".article-types"
  #   And I should see "Event" within ".article-types"
  #   And I should see "Uploaded file" within ".article-types"
  #   And I should not see "Folder" within ".article-types"
  #   And I should not see "Blog" within ".article-types"
  #   And I should not see "Gallery" within ".article-types"
  #   And I should not see "Forum" within ".article-types"
  #   And I should not see "RSS Feed" within ".article-types"
  #
  # Scenario: select directory to publish
  #   Given I am on joaosilva's profile
  #   And I follow "New Content"
  #   And I follow "Post to another directory"
  #   And I should see "In which directory do you want to publish?"
  #   And I should see "Gallery" within ".article-types"
  #   And I should see "Blog" within ".article-types"
  #   And I follow "Blog" within ".article-types"
  #   And I should see "You are publishing in Blog of Joao Silva"

  @selenium
  Scenario: select folder with subdirectories to publish
    Given I am on the homepage
    And I follow "New Content"
    And I follow "Folder"
    And I fill in "Title" with "My Folder"
    And I follow "Save"
    And I am on the homepage
    And I follow "New Content"
    And I follow "Folder"
    And I fill in "Title" with "My Sub Folder"
    And I select "joaosilva/My Folder" from "Parent folder:"
    And I follow "Save"
    And I am on the homepage
    And I follow "New Content"
    And I follow "Post to another directory"
    And I should see "In which directory do you want to publish?"
    And I should see "Blog"
    And I should see "Gallery"
    And I should see "My Folder"
    And I follow "My Folder"
    And I follow "Publish here" within ".folder-dropdown"
    And I should see "You are publishing in My Folder of Joao Silva"

  @selenium
  Scenario: select sub folder to publish
    Given I am on the homepage
    And I follow "New Content"
    And I follow "Folder"
    And I fill in "Title" with "My Folder"
    And I follow "Save"
    And I am on the homepage
    And I follow "New Content"
    And I follow "Folder"
    And I fill in "Title" with "My Sub Folder"
    And I select "joaosilva/My Folder" from "Parent folder:"
    And I follow "Save"
    And I am on the homepage
    And I follow "New Content"
    And I follow "Post to another directory"
    And I should see "In which directory do you want to publish?"
    And I should see "Blog"
    And I should see "Gallery"
    And I should see "My Folder"
    And I follow "My Folder"
    And I follow "See subdirectories" within ".folder-dropdown"
    And I follow "My Sub Folder"
    And I should see "You are publishing in My Sub Folder of Joao Silva"

  # Scenario: select my profile to publish
  #   Given I am on Sample Community's homepage
  #   And I follow "New Content" within "#navigation-actions"
  #   And I should see "You are publishing in profile of Sample Community"
  #   And I follow "Post to another profile"
  #   And I should see "In which profile do you want to publish?"
  #   And I follow "Joao Silva" within ".article-types"
  #   And I should see "You are publishing in profile of Joao Silva"
  #
  # Scenario: select enterprise profile to publish
  #   Given the following enterprises
  #     | identifier | name |
  #     | sample-enterprise | Sample Enterprise |
  #   And "Joao Silva" is admin of "Sample Enterprise"
  #   And I am on Joao Silva's homepage
  #   And I follow "New Content" within "#navigation-actions"
  #   And I should see "You are publishing in profile of Joao Silva"
  #   And I follow "Post to another profile"
  #   And I should see "In which profile do you want to publish?"
  #   And I follow "My enterprises" within ".article-types"
  #   And I follow "Sample Enterprise" within ".profile-selector-container"
  #   And I should see "You are publishing in profile of Sample Enterprise"
  #
  # Scenario: show user profile if him don't has permission to publish in current profile
  #   Given the following users
  #     | login     | name       |
  #     | mariajoana | Maria Joana |
  #   And I am on Maria Joana's homepage
  #   And I follow "New Content" within "#navigation-actions"
  #   And I should see "You are publishing in profile of Joao Silva"
  #
  # Scenario: show user profile if him don't has permission to publish in organization
  #   Given the following communities
  #     | identifier | name |
  #     | another-community | Another Community |
  #   And I am on Another Community's homepage
  #   And I follow "New Content" within "#navigation-actions"
  #   And I should see "You are publishing in profile of Joao Silva"
