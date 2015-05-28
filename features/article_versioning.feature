Feature: article versioning
  As a user
  I want to see article versions
  In order to be able to change between versions of an article

  Background:
    Given the following users
      | login     | name       |
      | joaosilva | Joao Silva |
    And "joaosilva" has no articles
    And the following articles
      | owner     | name           | body                                     | display_versions |
      | joaosilva | Sample Article | This is the first version of the article | true             |
    And the article "Sample Article" is updated with
      | name           | body                                      |
      | Edited Article | This is the second version of the article |
    And I am logged in as "joaosilva"

  @selenium
  Scenario: enabling visualization of versions
    Given the following articles
      | owner     | name        | body                       |
      | joaosilva | New Article | Article to enable versions |
   Given I am on article "New Article"
    Then I should not see "All versions"
    When I follow "Edit" within "#article-actions"
    And I check "I want this article to display a link to older versions"
    And I press "Save"
    Then I should be on article "New Article"
    And I should see "All versions"

  @selenium
  Scenario: list versions of an article
    Given I am on article "Edited Article"
    When I follow "All versions"
    Then I should be on /joaosilva/edited-article/versions
    And I should see "Version 1" within "#article-versions"
    And I should see "Version 2" within "#article-versions"

  @selenium
  Scenario: see specific version
    Given I go to article "Edited Article"
    Then I should see "Edited Article" within ".title"
    And I should see "This is the second version of the article" within ".article-body"
    When I follow "All versions"
    And I follow "Version 1"
    Then I should see "Sample Article" within ".title"
    And I should see "This is the first version of the article" within ".article-body"

  @selenium
  Scenario: revert to a specific version generates a new version
    Given I go to article "Edited Article"
    When I follow "All versions"
    Then I should not see "Version 3" within "#article-versions"
    And I follow "Version 1"
    And I follow "Revert to this version"
    And I press "Save"
    Then I should see "Sample Article" within ".title"
    When I follow "All versions"
    Then I should see "Version 3" within "#article-versions"

  Scenario: try to access versions of unexistent article
    Given I go to /joaosilva/unexistent-article/versions
    Then I should see "There is no such page"

  Scenario: deny access to versions when disabled on article
    Given the following articles
      | owner     | name              | body                        | display_versions |
      | joaosilva | Versions disabled | Versions can't be displayed | false            |
    And I go to /joaosilva/versions-disabled/versions
    Then I should see "Access denied"

  Scenario: deny access to specific version when disabled on article and not logged
    Given the article "Edited Article" is updated with
      | display_versions |
      | false            |
    And I am not logged in
    And I go to /joaosilva/edited-article?version=1
    Then I should see "Access denied"

  Scenario: deny access to specific version when disabled, private and not logged
    Given the article "Edited Article" is updated with
      | display_versions | published | show_to_followers |
      | false            | false     | false             |
    And I am not logged in
    And I go to /joaosilva/edited-article?version=1
    Then I should see "Access denied"
