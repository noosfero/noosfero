Feature: publish article
  As a user
  I want to publish an article
  In order to share it with other users

  Background:
    Given the following users
      | login | name |
      | joaosilva | Joao Silva |
      | mariasilva | Maria Silva |
    And "mariasilva" has no articles
    And "joaosilva" has no articles
    And the following communities
      | identifier | name |
      | sample-community | Sample Community |
    And the following articles
      | owner | name | body |
      | joaosilva | Sample Article | This is the first published article |

  Scenario: publishing an article that doesn't exists in the community
    Given I am logged in as "joaosilva"
    And "Joao Silva" is a member of "Sample Community"
    And I am on Joao Silva's control panel
    And I follow "Manage Content"
    And I follow "Spread"
    And I check "Sample Community"
    And I press "Spread this"
    And I go to Sample Community's sitemap
    When I follow "Sample Article"
    Then I should see "This is the first published article"

  Scenario: publishing an article with a different name
    Given I am logged in as "joaosilva"
    And "Joao Silva" is a member of "Sample Community"
    And I am on Joao Silva's control panel
    And I follow "Manage Content"
    And I follow "Spread"
    And I check "Sample Community"
    And I fill in "Title" with "Another name"
    And I press "Spread this"
    When I go to Sample Community's sitemap
    Then I should see "Another name"
    And I should not see "Sample Article"

  Scenario: getting an error message when publishing article with same name
    Given I am logged in as "joaosilva"
    And "Joao Silva" is a member of "Sample Community"
    And I am on Joao Silva's control panel
    And I follow "Manage Content"
    And I follow "Spread"
    And I check "Sample Community"
    And I press "Spread this"
    And I am not logged in
    And I am logged in as "mariasilva"
    And "Maria Silva" is a member of "Sample Community"
    And I am on Maria Silva's control panel
    And I follow "Manage Content"
    And I follow "New article"
    And I follow "Text article with Textile markup language"
    And I fill in the following:
      | Title | Sample Article |
      | Text | this is Maria's first published article |
    And I press "Save"
    And I follow "Spread"
    And I check "Sample Community"
    When I press "Spread this"
    Then I should see "The title (article name) is already being used by another article, please use another title."

  Scenario: publishing an article in many communities and listing the communities that couldn't publish the article again,
            stills publishing the article in the other communities.
    Given the following communities
      | identifier | name |
      | another-community1 | Another Community1 |
      | another-community2 | Another Community2 |
    And I am logged in as "joaosilva"
    And "Joao Silva" is a member of "Sample Community"
    And "Joao Silva" is a member of "Another Community1"
    And "Joao Silva" is a member of "Another Community2"
    And I am on Joao Silva's control panel
    And I follow "Manage Content"
    And I follow "Spread"
    And I check "Sample Community"
    And I press "Spread this"
    And I should not see "This article name is already in use in the following community(ies):"
    And I am on Joao Silva's control panel
    And I follow "Manage Content"
    And I follow "Spread"
    And I check "Sample Community"
    And I check "Another Community1"
    And I check "Another Community2"
    When I press "Spread this"
    Then I should see "The title (article name) is already being used by another article, please use another title."
    When I go to Another Community1's sitemap
    Then I should see "Sample Article"
    When I go to Another Community2's sitemap
    Then I should see "Sample Article"

  Scenario: ask to publish an article that was deleted before approval
    Given I am logged in as "joaosilva"
    And "Joao Silva" is admin of "Sample Community"
    And I am on Sample Community's control panel
    And I follow "Community Info and settings"
    And I choose "profile_data_moderated_articles_true"
    And I press "Save"
    And I am on Joao Silva's control panel
    And I follow "Manage Content"
    And I follow "Spread"
    And I check "Sample Community"
    And I press "Spread this"
    And "joaosilva" has no articles
    And I am on Sample Community's control panel
    When I follow "Tasks"
    Then I should see /Joao Silva wanted.*deleted/
    And I press "Ok!"
    Then I should not see /Joao Silva wanted.*deleted/
