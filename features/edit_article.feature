Feature: edit article
  As a noosfero user
  I want to create and edit articles

  Background:
    Given I am on the homepage
    And the following users
      | login     | name       |
      | joaosilva | Joao Silva |
    And the following articles
      | owner     | name              | body |
      | joaosilva | Save the whales   | ...  |
    And I am logged in as "joaosilva"

  Scenario: create a folder
    Given I am on joaosilva's control panel
    And I follow "Manage Content"
    And I follow "New content"
    When I follow "Folder"
    And I fill in "Title" with "My Folder"
    And I press "Save"
    And I go to joaosilva's control panel
    Then I should see "My Folder"

  @selenium
  Scenario: denied access folder for a not logged user
    Given the following communities
      | name           | identifier    | owner     |
      | Free Software  | freesoftware  | joaosilva |
    And the following users
      | login | name        |
      | mario | Mario Souto |
      | maria | Maria Silva |
    And "Mario Souto" is a member of "Free Software"
    And "Maria Silva" is a member of "Free Software"
    And I am on freesoftware's control panel
    And I follow "Manage Content"
    And I should see "New content"
    And I follow "New content"
    And I should see "Folder"
    When I follow "Folder"
    And I fill in "Title" with "My Folder"
    And I choose "article_published_false"
    And I press "Save"
    And I log off
    And I go to /freesoftware/my-folder
    Then I should see "Access denied"

  @selenium
  Scenario: Hide token field when show to members is activated
    Given the following communities
      | name           | identifier    | owner     |
      | Free Software  | freesoftware  | joaosilva |
    And the following users
      | login | name        |
      | mario | Mario Souto |
      | maria | Maria Silva |
    And "Mario Souto" is a member of "Free Software"
    And "Maria Silva" is a member of "Free Software"
    And I am on freesoftware's control panel
    And I follow "Manage Content"
    And I should see "New content"
    And I follow "New content"
    And I should see "Folder"
    When I follow "Folder"
    And I fill in "Title" with "My Folder"
    And I choose "article_published_false"
    And I check "article_show_to_followers"
    Then I should not see "Fill in the search"

  @selenium
  Scenario: show exception users field when you choose the private option
    Given the following communities
      | name           | identifier    | owner     |
      | Free Software  | freesoftware  | joaosilva |
    And the following users
      | login | name        |
      | mario | Mario Souto |
      | maria | Maria Silva |
    And "Mario Souto" is a member of "Free Software"
    And "Maria Silva" is a member of "Free Software"
    And I am on freesoftware's control panel
    And I follow "Manage Content"
    And I should see "New content"
    And I follow "New content"
    And I should see "Folder"
    When I follow "Folder"
    And I fill in "Title" with "My Folder"
    And I choose "article_published_false"
    Then I should see "Fill in the search field to add the exception users to see this content"

  @selenium
  Scenario: allowed user should see the content of a folder
    Given the following communities
      | name           | identifier    | owner     |
      | Free Software  | freesoftware  | joaosilva |
    And the following users
      | login | name        |
      | mario | Mario Souto |
      | maria | Maria Silva |
    And the following articles
      | owner        | name       | body |
      | freesoftware | My Folder  | ...  |
    And "Mario Souto" is a member of "Free Software"
    And "Maria Silva" is a member of "Free Software"
    And I go to /freesoftware/my-folder
    When I follow "Edit"
    And I choose "article_published_false"
    And I press "Save"
    And I add to "My Folder" the following exception "Maria Silva"
    And I am logged in as "maria"
    And I go to /freesoftware/my-folder
    Then I should see "My Folder"

  Scenario: redirect to the created folder
    Given I am on joaosilva's control panel
    And I follow "Manage Content"
    And I follow "New content"
    When I follow "Folder"
    And I fill in "Title" with "My Folder"
    And I press "Save"
    Then I should see "My Folder"
    And I should be on /joaosilva/my-folder

  Scenario: cancel button back to cms
    Given I am on joaosilva's control panel
    And I follow "Manage Content"
    And I follow "New content"
    And I follow "Folder"
    When I follow "Cancel" within ".main-block"
    Then I should be on joaosilva's cms

  @selenium
  Scenario: display tag list field when creating event
    Given I am on joaosilva's control panel
    And I follow "Manage Content"
    And I should see "New content"
    And I follow "New content"
    And I should see "Event" within ".article-types"
    When I follow "Event" within ".article-types"
    Then I should see "Tag list"

  Scenario: display tag list field when creating folder
    Given I am on joaosilva's control panel
    And I follow "Manage Content"
    And I follow "New content"
    And I should see "Folder"
    When I follow "Folder"
    Then I should see "Tag list"

  Scenario: create new article with tags
    Given I am on joaosilva's control panel
    And I follow "Manage Content"
    And I follow "New content"
    When I follow "Text article with Textile markup language"
    Then I should see "Tag list"
    When I fill in "Title" with "Article with tags"
    And I fill in "Tag list" with "aurium, bug"
    And I press "Save"
    And I go to /joaosilva/article-with-tags
    Then I should see "aurium" within "#article-tags"
    And I should see "bug" within "#article-tags"

  Scenario: redirect to the created article
    Given I am on joaosilva's control panel
    And I follow "Manage Content"
    When I follow "New content"
    When I follow "Text article with visual editor"
    And I fill in "Title" with "My Article"
    And I press "Save"
    Then I should see "My Article"
    And I should be on /joaosilva/my-article

  @selenium
  Scenario: edit an article
    Given I am on joaosilva's sitemap
    When I follow "Save the whales"
    And I follow "Edit"
    And I fill in "Title" with "My Article edited"
    And I press "Save"
    Then I should be on /joaosilva/my-article-edited

  @selenium
  Scenario: cancel button back to article when edit
    Given I am on joaosilva's sitemap
    When I follow "Save the whales"
    And I follow "Edit" within "#article-actions"
    And I follow "Cancel"
    Then I should be on /joaosilva/save-the-whales

  @selenium
  Scenario: create an article inside a folder
    Given I am on joaosilva's control panel
    When I follow "Manage Content"
    And I should see "New content"
    And I follow "New content"
    And I should see "Folder"
    And I follow "Folder"
    And I fill in "Title" with "My Folder"
    And I press "Save"
    Then I should be on /joaosilva/my-folder
    When I follow "New article"
    And I should see "Text article with visual editor"
    And I follow "Text article with visual editor"
    And I fill in "Title" with "My Article"
    And I press "Save"
    Then I should see "My Article"
    And I should be on /joaosilva/my-folder/my-article

  @selenium
  Scenario: cancel button back to folder after giving up creating
    Given I am on joaosilva's control panel
    When I follow "Manage Content"
    And I should see "New content"
    And I follow "New content"
    And I should see "Folder"
    And I follow "Folder"
    And I fill in "Title" with "My Folder"
    And I press "Save"
    Then I should be on /joaosilva/my-folder
    When I follow "New article"
    And I should see "Text article with visual editor"
    And I follow "Text article with visual editor"
    And I follow "Cancel" within ".no-boxes"
    Then I should be on /joaosilva/my-folder

  @selenium
  Scenario: save and continue
    Given I am on /joaosilva/save-the-whales
    And I follow "Edit"
    When I fill in "Text" with "new text"
    And I press "Save and continue"
    Then the "Text" field should contain "new text"
    And I should be on "Save the whales" edit page

  Scenario: save and continue when creating a new article
    Given I am on joaosilva's control panel
    When I follow "Manage Content"
    And I follow "New content"
    And I should see "Text article with visual editor"
    And I follow "Text article with visual editor"
    And I fill in "Title" with "My new article"
    And I fill in "Text" with "text for the new article"
    And I press "Save and continue"
    Then I should be on "My new article" edit page
    And the "Title" field should contain "My new article"
    And the "Text" field should contain "text for the new article"

  @selenium
  Scenario: add a translation to an article
    Given I am on joaosilva's sitemap
    And I follow "Save the whales"
    And the following languages "en es" are available on environment
    Then I should not see "Add translation"
    And I follow "Edit"
    And I select "English" from "Language"
    Then I press "Save"
    And I follow "Add translation"
    And I fill in "Title" with "Mi neuvo artículo"
    And I select "Español" from "Language"
    When I press "Save"
    Then I should be on /joaosilva/mi-neuvo-articulo
    And I should see "Translations"

  @selenium
  Scenario: not add a translation without a language
    Given the following articles
      | owner     | name               | language |
      | joaosilva | Article in English | en       |
    And I am on joaosilva's sitemap
    And the following languages "en pt" are available on environment
    When I follow "Article in English"
    And I follow "Add translation"
    And I fill in "Title" with "Article in Portuguese"
    And I press "Save"
    Then I should see "Language must be choosen"
    When I select "Português" from "Language"
    And I press "Save"
    Then I should not see "Language must be choosen"
    And I should be on /joaosilva/article-in-portuguese
