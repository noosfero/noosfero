Feature: uploads items on media panel
  As a noosfero user
  I want to uploads items when creating or editing articles

  Background:
    Given the following users
      | login     | name       |
      | joaosilva | Joao Silva |
    And feature "media_panel" is enabled on environment
    And I am logged in as "joaosilva"
    And I am on /myprofile/joaosilva/cms/new?type=TextArticle

  Scenario: see media panel collapsed
    Then I should see "Insert media"
      And I should not see an element ".show-media-panel"

  # issue #18
  @selenium-fixme
  Scenario: expand media panel
    When I follow "Show/Hide"
    Then I should see an element ".show-media-panel"

  # issue #18
  @selenium-fixme
  Scenario: upload file showing percentage and name
    When I follow "Show/Hide"
      And I attach the file "public/images/rails.png" to "file"
    Then I should see "100%"
      And I should see "rails.png"

  # issue #18
  @selenium-fixme
  Scenario: upload multiple files
    When I follow "Show/Hide"
      And I attach the file "public/images/rails.png" to "file"
      And I attach the file "public/503.jpg" to "file"
    Then I should see "rails.png" within "#file-1"
      And I should see "503.jpg" within "#file-2"

  # issue #18
  @selenium-fixme
  Scenario: show error when upload fails
    When I follow "Show/Hide"
    And I attach the file "public/images/rails.png" to "file"
    # uploads the same file twice to induce error (unique name validation)
    And I attach the file "public/images/rails.png" to "file"
    Then I should see "rails.png" within "#file-1"
    And I should see "100%" within "#file-1"
    But I should see "Validation failed: Slug The title (article name) is already being used by another article, please use another title." within "#file-2"
    And The page should contain "div.error-message"

  # issue #18
  @selenium-fixme
  Scenario: select destination folder
    When I follow "Show/Hide"
      And I attach the file "public/images/rails.png" to "file"
      And I select "joaosilva" from "parent_id" within "#media-upload-form"
      And I attach the file "public/503.jpg" to "file"
      And I go to joaosilva's cms
    Then I should not see "rails.png"
      But I should see "503"
    When I follow "Gallery"
    Then I should see "rails"
      But I should not see "503"

  # issue #18
  @selenium-fixme
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

  # issue #18
  @selenium-fixme
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

  # issue #18
  @selenium-fixme
  Scenario: hide and show upload list
    When I follow "Show/Hide"
      And I attach the file "public/images/rails.png" to "file"
      And I attach the file "public/503.jpg" to "file"
      And I follow "Hide all uploads"
    Then I should not see "503"
      And I should not see "rails"
    When I follow "Show all uploads"
    Then I should see "503"
      And I should see "rails"

  # issue #18
  @selenium-fixme
  Scenario: update recent media after file upload
    Given the following files
      | owner     | file          | mime       |
      | joaosilva | other-pic.jpg | image/jpeg |
    When I go to /myprofile/joaosilva/cms/new?type=TextArticle
      And I follow "Show/Hide"
      And I select "Recent media" from "parent_id" within "#published-media"
    Then I should see div with title "other-pic" within ".items"
    When I select "joaosilva" from "parent_id" within "#media-upload-form"
      And I attach the file "public/503.jpg" to "file"
    Then I should see div with title "503" within ".items"
      And I should see div with title "other-pic" within ".items"
    When I select "joaosilva/Gallery" from "parent_id" within "#media-upload-form"
      And I attach the file "public/images/rails.png" to "file"
      And I attach the file "public/robots.txt" to "file"
    Then I should see div with title "rails" within ".items"
      And I should see div with title "503" within ".items"
      And I should see div with title "other-pic" within ".items"
      And I should see "robots" link

  # issue #18
  @selenium-fixme
  Scenario: select folder to show items
    Given the following galleries
      | owner      | name          |
      | joaosilva  | other-gallery |
    And the following files
      | owner      | file          | mime       | parent        |
      | joaosilva  | rails.png     | image/png  | other-gallery |
      | joaosilva  | other-pic.jpg | image/jpeg | gallery       |
    When I go to /myprofile/joaosilva/cms/new?type=TextArticle
      And I follow "Show/Hide"
      And I select "joaosilva/Gallery" from "parent_id" within "#published-media"
    Then I should see div with title "other-pic" within ".items"
      And I should not see div with title "rails.png" within ".items"
    When I select "joaosilva/other-gallery" from "parent_id" within "#published-media"
    Then I should see div with title "rails" within ".items"
    And I should not see div with title "other-pic" within ".items"

  # issue #18
  @selenium-fixme
  Scenario: update selected folder content when upload file to same folder
    Given the following galleries
      | owner      | name          |
      | joaosilva  | other-gallery |
    And the following files
      | owner      | file          | mime       | parent        |
      | joaosilva  | other-pic.jpg | image/jpeg | gallery       |
    When I go to /myprofile/joaosilva/cms/new?type=TextArticle
      And I follow "Show/Hide"
      And I select "joaosilva/Gallery" from "parent_id" within "#published-media"
      And I select "joaosilva/Gallery" from "parent_id" within "#media-upload-form"
      And I attach the file "public/503.jpg" to "file"
    Then I should see div with title "other-pic" within ".items"
      And I should see div with title "503" within ".items"

    When I select "joaosilva/other-gallery" from "parent_id" within "#media-upload-form"
      And I attach the file "public/robots.txt" to "file"
    Then I should see div with title "other-pic" within ".items"
      And I should see div with title "503" within ".items"
      And I should not see "robots" within ".items"

  # issue #18
  @selenium-fixme
  Scenario: filter media with search
    Given the following galleries
      | owner      | name          |
      | joaosilva  | other-gallery |
    And the following files
      | owner      | file          | mime       | parent        |
      | joaosilva  | rails.png     | image/png  | other-gallery |
    When I go to /myprofile/joaosilva/cms/new?type=TextArticle
      And I follow "Show/Hide"
      And I select "Recent media" from "parent_id" within "#published-media"
      And I fill in "Search" with "rails" within "#published-media"
    Then I should see div with title "rails" within ".items"
    When I select "joaosilva/Gallery" from "parent_id" within "#published-media"
      And I fill in "Search" with "rails" within "#published-media"
    Then I should not see div with title "rails.png" within ".items"
    When I select "joaosilva/other-gallery" from "parent_id" within "#published-media"
      And I fill in "Search" with "rails" within "#published-media"
    Then I should see div with title "rails" within ".items"

  # issue #18
  @selenium-fixme
  Scenario: separete images from non-images
    When I follow "Show/Hide"
    Then I should not see "Images"
      And I should not see "Files"
    When I attach the file "public/robots.txt" to "file"
      And I attach the file "public/images/rails.png" to "file"
    Then I should see "Files"
      And I should see "robots" within ".generics"
      But I should not see "rails" within ".generics"
      And I should see "Images"
      And I should see div with title "rails" within ".images"
      But I should not see div with title "robots" within ".images"

  # issue #18
  @selenium-fixme
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
    When I go to /myprofile/joaosilva/cms/new?type=TextArticle
      And I follow "Show/Hide"
      And I should not see "View all"
      And I attach the file "public/503.jpg" to "file"
    Then I should see "View all" link
      And I should see div with title "503" within ".images"
