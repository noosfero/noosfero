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
    Given I am on Joao Silva's control panel
    And I follow "Manage Content"
    When I follow "New Folder"
    And I fill in "Title" with "My Folder"
    And I press "Save"
    And I go to Joao Silva's control panel
    Then I should see "My Folder"

  Scenario: redirect to the created folder
    Given I am on Joao Silva's control panel
    And I follow "Manage Content"
    When I follow "New Folder"
    And I fill in "Title" with "My Folder"
    And I press "Save"
    Then I should see "My Folder"
    And I should be on /joaosilva/my-folder

  Scenario: cancel button back to cms
    Given I go to the Control panel
    And I follow "Manage Content"
    And I follow "New Folder"
    When I follow "Cancel" within ".main-block"
    Then I should be on Joao Silva's cms

  Scenario: display tag list field when creating event
    Given I go to the Control panel
    And I follow "Manage Content"
    And I follow "New article"
    When I follow "Event"
    Then I should see "Tag list"

  Scenario: display tag list field when creating folder
    Given I go to the Control panel
    And I follow "Manage Content"
    When I follow "New folder"
    Then I should see "Tag list"

  Scenario: create new article with tags
    Given I go to the Control panel
    And I follow "Manage Content"
    And I follow "New article"
    When I follow "Text article with Textile markup language"
    Then I should see "Tag list"
    When I fill in "Title" with "Article with tags"
    And I fill in "Tag list" with "aurium, bug"
    And I press "Save"
    And I go to /joaosilva/article-with-tags
    Then I should see "aurium" within "#article-tags a:first"
    And I should see "bug" within "#article-tags a:last"

  Scenario: redirect to the created article
    Given I am on Joao Silva's control panel
    And I follow "Manage Content"
    When I follow "New article"
    When I follow "Text article with visual editor"
    And I fill in "Title" with "My Article"
    And I press "Save"
    Then I should see "My Article"
    And I should be on /joaosilva/my-article

  Scenario: edit an article
    Given I am on Joao Silva's sitemap
    And I follow "Save the whales"
    And I follow "Edit"
    And I fill in "Title" with "My Article edited"
    When I press "Save"
    Then I should be on /joaosilva/my-article-edited

  Scenario: cancel button back to article when edit
    Given I am on Joao Silva's sitemap
    And I follow "Save the whales"
    And I follow "Edit"
    When I follow "Cancel" within ".main-block"
    Then I should be on /joaosilva/save-the-whales

  Scenario: create an article inside a folder
    Given I am on Joao Silva's control panel
    And I follow "Manage Content"
    And I follow "New Folder"
    And I fill in "Title" with "My Folder"
    And I press "Save"
    Then I should be on /joaosilva/my-folder
    When I follow "New article"
    And I follow "Text article with visual editor"
    And I fill in "Title" with "My Article"
    And I press "Save"
    Then I should see "My Article"
    And I should be on /joaosilva/my-folder/my-article

  Scenario: cancel button back to folder after giving up creating
    Given I am on Joao Silva's control panel
    And I follow "Manage Content"
    And I follow "New Folder"
    And I fill in "Title" with "My Folder"
    And I press "Save"
    Then I should be on /joaosilva/my-folder
    When I follow "New article"
    And I follow "Text article with visual editor"
    When I follow "Cancel" within ".no-boxes"
    And I should be on /joaosilva/my-folder

  Scenario: save and continue
    Given I am on /joaosilva/save-the-whales
    And I follow "Edit"
    When I fill in "Text" with "new text"
    And I press "Save and continue"
    Then the "Text" field should contain "new text"
    And I should be on "Save the whales" edit page

  Scenario: save and continue when creating a new article
    Given I am on Joao Silva's control panel
    When I follow "Manage Content"
    And I follow "New article"
    And I follow "Text article with visual editor"
    And I fill in "Title" with "My new article"
    And I fill in "Text" with "text for the new article"
    And I press "Save and continue"
    Then I should be on "My new article" edit page
    And the "Title" field should contain "My new article"
    And the "Text" field should contain "text for the new article"

  Scenario: add a translation to an article
    Given I am on Joao Silva's sitemap
    And I follow "Save the whales"
    Then I should not see "Add translation"
    And I follow "Edit"
    And I select "English" from "Language"
    Then I press "Save"
    And I follow "Add translation"
    And I fill in "Title" with "Mi neuvo artículo"
    And I select "Español" from "Language"
    When I press "Save"
    Then I should be on /joaosilva/save-the-whales
    And I should see "Translations"

  Scenario: not add a translation without a language
    Given the following articles
      | owner     | name               | language |
      | joaosilva | Article in English | en       |
    And I am on Joao Silva's sitemap
    And I follow "Article in English"
    And I follow "Add translation"
    And I fill in "Title" with "Article in Portuguese"
    When I press "Save"
    Then I should see "Language must be choosen"
    And I select "Português" from "Language"
    When I press "Save"
    Then I should not see "Language must be choosen"
    And I should be on /joaosilva/article-in-english
