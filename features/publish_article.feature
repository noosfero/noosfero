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

  @selenium
  Scenario: publishing an article that doesn't exists in the community
    Given I am logged in as "joaosilva"
    And "Joao Silva" is a member of "Sample Community"
    And I am on joaosilva's control panel
    And I follow "Manage Content"
    And I follow "Spread"
    And I type in "Sample Community" into autocomplete list "search-communities-to-publish" and I choose "Sample Community"
    And I press "Spread this"
    When I go to sample-community's sitemap
    Then I should see "Sample Article"

  @selenium
  Scenario: publishing an article with a different name
    Given I am logged in as "joaosilva"
    And "Joao Silva" is a member of "Sample Community"
    And I am on joaosilva's control panel
    And I follow "Manage Content"
    And I follow "Spread"
    And I choose the following communities to spread
      | name             |
      | Sample Community |
    And I fill in "Title" with "Another name"
    And I press "Spread this"
    When I go to sample-community's blog
    Then I should see "Another name"
    And I should not see "Sample Article"

  @selenium @ignore-hidden-elements
  Scenario: getting an error message when publishing article with same name
    Given I am logged in as "joaosilva"
    And "Joao Silva" is a member of "Sample Community"
    And I am on joaosilva's control panel
    And I follow "Manage Content"
    And I follow "Spread"
    And I type in "Sample Community" into autocomplete list "search-communities-to-publish" and I choose "Sample Community"
    And I press "Spread this"
    And I am not logged in
    And I am logged in as "mariasilva"
    And "Maria Silva" is a member of "Sample Community"
    And I am on mariasilva's control panel
    And I follow "Manage Content"
    And I follow "New content"
    And I should see "Text article with Textile markup language"
    And I follow "Text article with Textile markup language"
    And I fill in the following:
      | Title | Sample Article |
      | Text | this is Maria's first published article |
    And I press "Save"
    And I follow "Spread"
    And I type in "Sample Community" into autocomplete list "search-communities-to-publish" and I choose "Sample Community"
    When I press "Spread this"
    Then I should see "The title (article name) is already being used by another article, please use another title."

  @selenium
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
    And I am on joaosilva's control panel
    And I follow "Manage Content"
    And I follow "Spread"
    And I type in "Sample Community" into autocomplete list "search-communities-to-publish" and I choose "Sample Community"
    And I press "Spread this"
    And I should not see "This article name is already in use in the following community(ies):"
    And I am on joaosilva's control panel
    And I follow "Manage Content"
    And I follow "Spread"
    And I type in "Sample Community" into autocomplete list "search-communities-to-publish" and I choose "Sample Community"
    And I type in "Another Community1" into autocomplete list "search-communities-to-publish" and I choose "Another Community1"
    And I type in "Another Community2" into autocomplete list "search-communities-to-publish" and I choose "Another Community2"
    When I press "Spread this"
    Then I should see "The title (article name) is already being used by another article, please use another title."
    When I go to another-community1's sitemap
    Then I should see "Sample Article"
    When I go to another-community2's sitemap
    Then I should see "Sample Article"

  @selenium
  Scenario: publishing articles with the same name in a moderated community
    Given I am logged in as "joaosilva"
    And "Joao Silva" is a member of "Sample Community"
    And "Joao Silva" is admin of "Sample Community"
    And I am on sample-community's control panel
    And I follow "Community Info and settings"
    And I choose "profile_data_moderated_articles_true"
    And I press "Save"
    And I am on joaosilva's control panel
    And I follow "Manage Content"
    And I follow "Spread"
    And I type in "Sample Community" into autocomplete list "search-communities-to-publish" and I choose "Sample Community"
    And I press "Spread this"
    And I am on joaosilva's control panel
    And I follow "Manage Content"
    And I follow "Spread"
    And I type in "Sample Community" into autocomplete list "search-communities-to-publish" and I choose "Sample Community"
    And I press "Spread this"
    And I am on sample-community's control panel
    And I follow "Tasks"
    And I choose "Accept"
    And I press "Apply!"
    And I should not see "The title (article name) is already being used by another article, please use another title."
    And I choose "Accept"
    When I press "Apply!"
    Then I should see "The title (article name) is already being used by another article, please use another title."

  @selenium
  Scenario: ask to publish an article that was deleted before approval
    Given I am logged in as "joaosilva"
    And "Joao Silva" is admin of "Sample Community"
    And I am on sample-community's control panel
    And I follow "Community Info and settings"
    And I choose "profile_data_moderated_articles_true"
    And I press "Save"
    And I am on joaosilva's control panel
    And I follow "Manage Content"
    And I follow "Spread"
    And I type in "Sample Community" into autocomplete list "search-communities-to-publish" and I choose "Sample Community"
    And I press "Spread this"
    And "joaosilva" has no articles
    And I am on sample-community's control panel
    When I follow "Tasks"
    Then I should see "The article was removed."
    And I press "Apply!"
    Then I should not see "The article was removed."
