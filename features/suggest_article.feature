Feature: suggest article
  As a not logged user
  I want to suggest an article
  In order to share it with other users

  Background:
    Given the following users
      | login | name |
      | joaosilva | Joao Silva |
    And the following communities
      | identifier | name |
      | sample-community | Sample Community |
    And "Joao Silva" is admin of "Sample Community"

  Scenario: highlight an article before approval of a suggested article
    Given someone suggested the following article to be published
      | target           | article_name        | article_body                    | name | email            |
      | sample-community | A suggested article | this is an article about whales | jose | jose@example.org |
    When I am logged in as "joaosilva"
    And I go to Sample Community's control panel
    And I follow "Process requests"
    And I should see "suggested the publication of the article"
    Then I should see "Highlight this article" within ".task_box"
