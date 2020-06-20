Feature: forum
  As a noosfero user
  I want to have one or mutiple forums

  Background:
    Given I am on the homepage
    And the following users
      | login     | name       |
      | joaosilva | Joao Silva |
    And "joaosilva" has no articles
    And I am logged in as "joaosilva"

  @selenium @ignore-hidden-elements
  Scenario: create a forum
    Given I am on joaosilva's control panel
    And I follow "Manage" within "#section-content"
    And I follow "New content"
    And I follow "Forum"
    And I fill in "Title" with "My Forum"
    And I follow "Save"
    When I follow "article-options"
    Then I should see "Configure forum"

  @selenium
  Scenario: redirect to forum after create forum from cms
    Given I go to joaosilva's control panel
    And I follow "Manage" within "#section-content"
    And I follow "New content"
    And I follow "Forum"
    And I fill in "Title" with "Forum from cms"
    And I follow "Save"
    Then I should be on /joaosilva/forum-from-cms

  @selenium
  Scenario: create multiple forums
    Given I go to joaosilva's control panel
    And I follow "Manage" within "#section-content"
    And I follow "New content"
    And I follow "Forum"
    And I fill in "Title" with "Title One"
    And I follow "Save"
    Then I go to joaosilva's control panel
    And I follow "Manage" within "#section-content"
    And I follow "New content"
    And I follow "Forum"
    And I fill in "Title" with "Title Two"
    And I follow "Save"
    Then I should not see "error"
    And I should be on /joaosilva/title-two


  @selenium
  Scenario: cancel button back to cms
    Given I go to joaosilva's control panel
    And I follow "Manage" within "#section-content"
    And I follow "New content"
    And I follow "Forum"
    When I follow "Cancel" within ".main-block"
    Then I should be on /myprofile/joaosilva/cms

  @selenium
  Scenario: configure forum when viewing it
    Given the following forums
       | owner     | name      |
       | joaosilva | Forum One |
    And I go to /joaosilva/forum-one
    And I follow "article-options"
    When I follow "Configure forum"
    Then I should be on edit "Forum One" by joaosilva

  @selenium
  Scenario: show forum with terms of use for owner
    Given the following forums
       | owner     | name      |
       | joaosilva | Forum One |
    And I go to /joaosilva/forum-one
    And I follow "article-options"
    When I follow "Configure forum"
    And I fill in tinyMCE "article_body" with "My description"
    And I check "Has terms of use:"
    And I follow "Save"
    Then I should see "Forum One"
    And I should see "My description"

  @selenium
  Scenario: accept terms in topics page
    Given the following forums
       | owner     | name      |
       | joaosilva | Forum One |
    And the following users
       | login      | name        |
       | mariasilva | Maria Silva |
    And I go to /joaosilva/forum-one
    And I follow "article-options"
    When I follow "Configure forum"
    And I fill in tinyMCE "article_body" with "My description"
    And I check "Has terms of use:"
    And I follow "Save"
    And I follow "article-options"
    When I follow "New discussion topic"
    And I should see "Text article"
    And I follow "Text article"
    And I fill in "Title" with "Topic"
    And I follow "Save"
    And I am logged in as "mariasilva"
    And I go to /joaosilva/forum-one/topic
    And I follow "Accept"
    Then I should see "Topic"

  @selenium
  Scenario: accept terms of use of a forum for others users
    Given the following forums
       | owner     | name      |
       | joaosilva | Forum One |
    And the following users
       | login      | name        |
       | mariasilva | Maria Silva |
    And I go to /joaosilva/forum-one
    And I follow "article-options"
    When I follow "Configure forum"
    And I fill in tinyMCE "article_body" with "My description"
    And I check "Has terms of use:"
    And I follow "Save"
    And I follow "menu-dropdown"
    When I follow "Logout"
    And I am logged in as "mariasilva"
    And I go to /joaosilva/forum-one?terms=terms
    When I follow "Accept"
    And I wait for 1 second
    Then I should see "Forum One"
    And I should see "My description"

  @selenium
  Scenario: redirect user not logged
    Given the following forums
       | owner     | name      |
       | joaosilva | Forum One |
    And I go to /joaosilva/forum-one
    And I follow "article-options"
    When I follow "Configure forum"
    And I fill in tinyMCE "article_body" with "My description"
    And I check "Has terms of use:"
    And I follow "Save"
    And I follow "menu-dropdown"
    When I follow "Logout"
    And I wait for 1 seconds
    And I go to /joaosilva/forum-one?terms=terms
    When I follow "Accept"
    Then I should see "Login" within ".login-box"

  @selenium
  Scenario: last topic update by unautenticated user should not link
    Given the following forums
       | owner     | name  |
       | joaosilva | Forum |
    And the following articles
       | owner     | name     | parent |
       | joaosilva | Post one | Forum  |
    And the following comments
       | article  | name | email            | title  | body   |
       | Post one | Joao | joao@example.com | Hi all | Hi all |
   When I go to /joaosilva/forum
   Then I should not see "Joao" linking to "#"

  @selenium
  Scenario: last topic update by autenticated user should link to profile url
    Given the following forums
       | owner     | name  |
       | joaosilva | Forum |
    And the following articles
       | owner     | name     | parent |
       | joaosilva | Post one | Forum  |
    And the following comments
       | article  | author    | title  | body   |
       | Post one | joaosilva | Hi all | Hi all |
   When I go to /joaosilva/forum
   Then I should see "Joao Silva" within ".forum-post-last-answer"

  Scenario: link to parent when viewing a forum topic
    Given the following forums
       | owner     | name        |
       | joaosilva | Silva Forum |
    And the following articles
       | owner     | name     | parent       |
       | joaosilva | Post one | Silva Forum  |
   When I go to /joaosilva/silva-forum/post-one
   Then I should see "Silva Forum" within ".path-to-parents"
