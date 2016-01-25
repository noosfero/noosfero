Feature:
  As a logged user
  I want to manage a recent content block

Background:
  Given the following users
    | login      |  name      |
    | joaosilva  | Joao Silva |
  And the following plugin
    | klass          |
    | RecentContent |
  And plugin RecentContent is enabled on environment
  And the following blocks
    | owner     |         type       |
    | joaosilva | RecentContentBlock |
  And the following blogs
    | owner     | name        |
    | joaosilva | JSilva blog |
  And the following articles
    | owner     | parent      | name    | body                        | abstract |
    | joaosilva | JSilva blog | post #1 | Primeiro post do joao silva | Resumo 1 |
    | joaosilva | JSilva blog | post #2 | Segundo post do joao silva  | Resumo 2 |
    | joaosilva | JSilva blog | post #3 | Terceiro post do joao silva | Resumo 3 |
    | joaosilva | JSilva blog | post #4 | Quarto post do joao silva   | Resumo 4 |
    | joaosilva | JSilva blog | post #5 | Quinto post do joao silva   | Resumo 5 |
    | joaosilva | JSilva blog | post #6 | Sexto post do joao silva    | Resumo 6 |
  And I am logged in as "joaosilva"
    Given I go to joaosilva's control panel
    And I follow "Edit sideboxes"

  Scenario: the block is being displayed
    Then I should see "This is the recent content block. Please edit it to show the content you want."

  Scenario: a user should be redirected to the post page when the link is clicked
    When I follow "Edit" within ".block.recent-content-block"
    And I select "JSilva blog" from "Choose which blog should be displayed"
    And I select "Title only" from "Choose how the content should be displayed"
    And I fill in "Choose how many items will be displayed" with "3"
    And I press "Save"
    And I follow "post #4" within ".block.recent-content-block"
    Then I should be on /joaosilva/jsilva-blog/post-4

  Scenario: a user should be redirected to the blog page when the "view all" is clicked
    When I follow "Edit" within ".block.recent-content-block"
    And I select "JSilva blog" from "Choose which blog should be displayed"
    And I select "Title only" from "Choose how the content should be displayed"
    And I fill in "Choose how many items will be displayed" with "2"
    And I press "Save"
    And I follow "View All"
    Then I should be on /joaosilva/jsilva-blog

  Scenario: a user should see only titles if the block was configured for it
    When I follow "Edit" within ".block.recent-content-block"
    And I select "JSilva blog" from "Choose which blog should be displayed"
    And I select "Title only" from "Choose how the content should be displayed"
    And I fill in "Choose how many items will be displayed" with "3"
    And I press "Save"
    Then I should see "post #6" within ".block.recent-content-block"

  Scenario: a user should see titles and abstract if the block was configured for it
    When I follow "Edit" within ".block.recent-content-block"
    And I select "JSilva blog" from "Choose which blog should be displayed"
    And I select "Title and abstract" from "Choose how the content should be displayed"
    And I fill in "Choose how many items will be displayed" with "6"
    And I press "Save"
    Then I should see "Resumo 5" within ".block.recent-content-block"

  Scenario: a user should see full content if the block was configured for it
    When I follow "Edit" within ".block.recent-content-block"
    And I select "JSilva blog" from "Choose which blog should be displayed"
    And I select "Full content" from "Choose how the content should be displayed"
    And I fill in "Choose how many items will be displayed" with "6"
    And I press "Save"
    Then I should see "Quinto post do joao silva" within ".block.recent-content-block"

  Scenario: the user should see the blog cover image if configured and the image is available
    Given I go to joaosilva's control panel
    And I follow "Configure blog"
    And I follow "Edit" within "tr[title='JSilva blog']"
    And I attach the file "public/images/rails.png" to "Uploaded data"
    And I press "Save"
    When I go to joaosilva's control panel
    And I follow "Edit sideboxes"
    And I follow "Edit" within ".block.recent-content-block"
    And I select "JSilva blog" from "Choose which blog should be displayed"
    And I select "Title only" from "Choose how the content should be displayed"
    And I fill in "Choose how many items will be displayed" with "3"
    And I check "Display blog cover image"
    And I press "Save"
    Then there should be a div with class "recent-content-cover"
