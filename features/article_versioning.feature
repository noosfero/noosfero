Feature: article versioning
  As a user
  I want to see article versions
  In order to be able to change between versions of an article

  Background:
    Given the following users
      | login | name |
      | joaosilva | Joao Silva |
    And "joaosilva" has no articles
    And the following articles
      | owner | name | body |
      | joaosilva | Sample Article | This is the first version of the article |
    And the article "Sample Article" is updated with
      | name | body |
      | Edited Article | This is the second version of the article |
    And I am logged in as "joaosilva"

  Scenario: display only link for original version
    Given the following articles
      | owner | name | body |
      | joaosilva | One version article | This is the first published article |
    And I am on joaosilva's control panel
    And I follow "Manage Content"
    When I follow "One version article"
    Then I should see "r1" within "#article-versions"
    And I should not see "r2" within "#article-versions"

  Scenario: display links for versions
    Given I am on joaosilva's control panel
    And I follow "Manage Content"
    When I follow "Edited Article"
    Then I should see "r1" within "#article-versions"
    And I should see "r2" within "#article-versions"

  Scenario: display links for versions
    Given I am on joaosilva's control panel
    And I follow "Manage Content"
    And I follow "Edited Article" 
    When I follow "r2" within "#article-versions"
    Then I should see "This is the first version of the article" within ".article-body"
