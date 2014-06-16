Feature: caching
  As a user
  I want to see the contents according with my language
  Even with the contents being cached

  Background:
    Given the cache is turned on
    And the following user
      | login | name        |
      | mario | Mario |
    And I am logged in as "mario"

  Scenario: blog view page
    Given the following blogs
      | owner | name         | display_posts_in_current_language | visualization_format |
      | mario | Sample Blog  | false                             | short                |
    And the following articles
      | owner | name  | parent       |
      | mario | Post1 | Sample Blog  |
      | mario | Post2 | Sample Blog  |
    When I go to article "Sample Blog"
    Then I should see "no comments yet"
    When I follow "Português"
    Then I should see "sem comentários ainda"

  Scenario: blocks
    Given I am on Mario's homepage
    Then I should see "Recent content"
    When I follow "Português"
    Then I should see "Conteúdo recente"
