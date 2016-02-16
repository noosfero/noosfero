Feature: uploads items on media panel
  As a noosfero user
  I want to uploads items when creating or editing articles

  Background:
    Given the following users
      | login     | name       |
      | joaosilva | Joao Silva |
    And feature "media_panel" is enabled on environment
    And I am logged in as "joaosilva"
    And I am on /myprofile/joaosilva/cms/new?type=TinyMceArticle

  Scenario: see media panel collapsed
    Then I should see "Insert media"
      And I should not see an element ".show-media-panel"

  @selenium
  Scenario: expand media panel
    When I follow "Show/Hide"
    Then I should see an element ".show-media-panel"

  @selenium
  Scenario: upload file showing percentage and name
    When I follow "Show/Hide"
      And I attach the file "public/images/rails.png" to "file"
    Then I should see "100%"
      And I should see "rails.png"

  @selenium
  Scenario: upload multiple files
    When I follow "Show/Hide"
      And I attach the file "public/images/rails.png" to "file"
      And I attach the file "public/503.jpg" to "file"
    Then I should see "rails.png" within "#file-1"
      And I should see "503.jpg" within "#file-2"

  @selenium
  Scenario: show error when upload fails
    When I follow "Show/Hide"
      And I attach the file "public/images/rails.png" to "file"
      # uploads the same file twice to induce error (unique name validation)
      And I attach the file "public/images/rails.png" to "file"
    Then I should see "rails.png" within "#file-1"
      And I should see "100%" within "#file-1"
      But I should see "Validation failed: Slug The title (article name) is already being used by another article, please use another title." within "#file-2"
      And The page should contain "div.error-message"

  @selenium
  Scenario: select destination folder
    When I follow "Show/Hide"
      And I attach the file "public/images/rails.png" to "file"
      And I select "joaosilva" from "parent_id" within "#media-upload-form"
      And I attach the file "public/503.jpg" to "file"
      And I go to joaosilva's cms
    Then I should not see "rails.png"
      But I should see "503.jpg"
    When I follow "Gallery"
    Then I should see "rails.png"
      But I should not see "503.jpg"

  @selenium
  Scenario: create new folder with parent
    Given I follow "Show/Hide"
      And I should see "joaosilva" within "#media-upload-form"
      And I should see "joaosilva/Gallery" within "#media-upload-form"
      And I should see "joaosilva" within "#published-media"
      And I should see "joaosilva/Gallery" within "#published-media"

    When I follow "New folder"
      And I select "joaosilva" from "parent_id" within "#new-folder-dialog"
      And I fill in "Name" with "Main folder" within "#new-folder-dialog"
      And I press "Create"
    Then I should see "joaosilva" within "#media-upload-form"
      And I should see "joaosilva/Gallery" within "#media-upload-form"
      And I should see "joaosilva/Main folder" within "#media-upload-form"
      And "joaosilva/Main folder" should be selected for "parent_id" within "#media-upload-form"
      And I should see "joaosilva" within "#published-media"
      And I should see "joaosilva/Gallery" within "#published-media"
      And I should see "joaosilva/Main folder" within "#published-media"

    When I follow "New folder"
      And I select "joaosilva/Gallery" from "parent_id" within "#new-folder-dialog"
      And I fill in "Name" with "Gallery folder" within "#new-folder-dialog"
      And I press "Create"
    Then I should see "joaosilva" within "#media-upload-form"
      And I should see "joaosilva/Gallery" within "#media-upload-form"
      And I should see "joaosilva/Main folder" within "#media-upload-form"
      And I should see "joaosilva/Gallery/Gallery folder" within "#media-upload-form"
      And "joaosilva/Gallery/Gallery folder" should be selected for "parent_id" within "#media-upload-form"
      And I should see "joaosilva" within "#published-media"
      And I should see "joaosilva/Gallery" within "#published-media"
      And I should see "joaosilva/Main folder" within "#published-media"
      And I should see "joaosilva/Gallery/Gallery folder" within "#published-media"

  @selenium
  Scenario: select type when create new folder
    Given I follow "Show/Hide"
    And I follow "New folder"
    And I choose "Folder" within "#new-folder-dialog"
    And I fill in "Name" with "Main new folder" within "#new-folder-dialog"
    When I press "Create"
    Then I should see "joaosilva/Gallery/Main new folder" within "#parent_id"
    Given I follow "New folder"
    And I choose "Gallery" within "#new-folder-dialog"
    And I fill in "Name" with "Gallery new folder" within "#new-folder-dialog"
    When I press "Create"
    Then I should see "joaosilva/Gallery/Gallery new folder" within "#parent_id"

  @selenium
  Scenario: hide and show upload list
    When I follow "Show/Hide"
      And I attach the file "public/images/rails.png" to "file"
      And I attach the file "public/503.jpg" to "file"
      And I follow "Hide all uploads"
    Then I should not see "503.jpg"
      And I should not see "rails.png"
    When I follow "Show all uploads"
    Then I should see "503.jpg"
      And I should see "rails.png"

  @selenium
  Scenario: update recent media after file upload
    Given the following files
      | owner     | file          | mime       |
      | joaosilva | other-pic.jpg | image/jpeg |
    When I go to /myprofile/joaosilva/cms/new?type=TinyMceArticle
      And I follow "Show/Hide"
      And I select "Recent media" from "parent_id" within "#published-media"
    Then I should see div with title "other-pic.jpg" within ".items"
    When I select "joaosilva" from "parent_id" within "#media-upload-form"
      And I attach the file "public/503.jpg" to "file"
    Then I should see div with title "503.jpg" within ".items"
      And I should see div with title "other-pic.jpg" within ".items"
    When I select "joaosilva/Gallery" from "parent_id" within "#media-upload-form"
      And I attach the file "public/images/rails.png" to "file"
      And I attach the file "public/robots.txt" to "file"
    Then I should see div with title "rails.png" within ".items"
      And I should see div with title "503.jpg" within ".items"
      And I should see div with title "other-pic.jpg" within ".items"
      And I should see "robots.txt" link

  @selenium
  Scenario: select folder to show items
    Given the following galleries
      | owner      | name          |
      | joaosilva  | other-gallery |
    And the following files
      | owner      | file          | mime       | parent        |
      | joaosilva  | rails.png     | image/png  | other-gallery |
      | joaosilva  | other-pic.jpg | image/jpeg | gallery       |
    When I go to /myprofile/joaosilva/cms/new?type=TinyMceArticle
      And I follow "Show/Hide"
      And I select "joaosilva/Gallery" from "parent_id" within "#published-media"
    Then I should see div with title "other-pic.jpg" within ".items"
      And I should not see div with title "rails.png" within ".items"
    When I select "joaosilva/other-gallery" from "parent_id" within "#published-media"
    Then I should see div with title "rails.png" within ".items"
      And I should not see div with title "other-pic.jpg" within ".items"

  @selenium
  Scenario: update selected folder content when upload file to same folder
    Given the following galleries
      | owner      | name          |
      | joaosilva  | other-gallery |
    And the following files
      | owner      | file          | mime       | parent        |
      | joaosilva  | other-pic.jpg | image/jpeg | gallery       |
    When I go to /myprofile/joaosilva/cms/new?type=TinyMceArticle
      And I follow "Show/Hide"
      And I select "joaosilva/Gallery" from "parent_id" within "#published-media"
      And I select "joaosilva/Gallery" from "parent_id" within "#media-upload-form"
      And I attach the file "public/503.jpg" to "file"
    Then I should see div with title "other-pic.jpg" within ".items"
      And I should see div with title "503.jpg" within ".items"

    When I select "joaosilva/other-gallery" from "parent_id" within "#media-upload-form"
      And I attach the file "public/robots.txt" to "file"
    Then I should see div with title "other-pic.jpg" within ".items"
      And I should see div with title "503.jpg" within ".items"
      And I should not see "robots.txt" within ".items"

  @selenium
  Scenario: filter media with search
    Given the following galleries
      | owner      | name          |
      | joaosilva  | other-gallery |
    And the following files
      | owner      | file          | mime       | parent        |
      | joaosilva  | rails.png     | image/png  | other-gallery |
    When I go to /myprofile/joaosilva/cms/new?type=TinyMceArticle
      And I follow "Show/Hide"
      And I select "Recent media" from "parent_id" within "#published-media"
      And I fill in "Search" with "rails" within "#published-media"
    Then I should see div with title "rails.png" within ".items"
    When I select "joaosilva/Gallery" from "parent_id" within "#published-media"
      And I fill in "Search" with "rails" within "#published-media"
    Then I should not see div with title "rails.png" within ".items"
    When I select "joaosilva/other-gallery" from "parent_id" within "#published-media"
      And I fill in "Search" with "rails" within "#published-media"
    Then I should see div with title "rails.png" within ".items"

  @selenium
  Scenario: separete images from non-images
    When I follow "Show/Hide"
    Then I should not see "Images"
      And I should not see "Files"
    When I attach the file "public/robots.txt" to "file"
      And I attach the file "public/images/rails.png" to "file"
    Then I should see "Files"
      And I should see "robots.txt" within ".generics"
      But I should not see "rails.png" within ".generics"
      And I should see "Images"
      And I should see div with title "rails.png" within ".images"
      But I should not see div with title "robots.txt" within ".images"

  @selenium
  Scenario: view all media button if there are too many uploads
    Given the following galleries
      | owner      | name          |
      | joaosilva  | other-gallery |
      | joaosilva  | my-gallery    |
    And the following files
      | owner      | file          | mime       | parent        |
      | joaosilva  | rails.png     | image/png  | other-gallery |
      | joaosilva  | other-pic.jpg | image/jpeg | other-gallery |
      | joaosilva  | rails.png     | image/png  | my-gallery    |
      | joaosilva  | other-pic.jpg | image/jpeg | my-gallery    |
      | joaosilva  | rails.png     | image/png  | gallery       |
      | joaosilva  | other-pic.jpg | image/jpeg | gallery       |
    When I go to /myprofile/joaosilva/cms/new?type=TinyMceArticle
      And I follow "Show/Hide"
      And I should not see "View all"
      And I attach the file "public/503.jpg" to "file"
    Then I should see "View all" link
      And I should see div with title "503.jpg" within ".images"
