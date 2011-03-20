Feature: approve article
  As a community admin
  I want to approve an article
  In order to share it with other users

  Background:
    Given the following users
      | login | name |
      | joaosilva | Joao Silva |
      | mariasilva | Maria Silva |
    And the following articles
      | owner | name | body | homepage |
      | mariasilva | Sample Article | This is an article | true |
    And the following communities
      | identifier | name |
      | sample-community | Sample Community |
    And the articles of "Sample Community" are moderated
    And "Maria Silva" is a member of "Sample Community"
    And "Joao Silva" is admin of "Sample Community"

  @selenium
  Scenario: edit an article before approval
    Given I am logged in as "mariasilva"
    And I am on Maria Silva's homepage
    When I follow "Spread" and wait
    And I check "Sample Community"
    And I press "Spread this"
    And I am logged in as "joaosilva"
    And I go to Sample Community's control panel
    And I follow "Process requests" and wait
    And I fill in "Text" with "This is an article edited"
    And I choose "Accept"
    And I press "Apply!"
    And I go to Sample Community's sitemap
    And I follow "Sample Article"
    Then I should see "This is an article edited"
