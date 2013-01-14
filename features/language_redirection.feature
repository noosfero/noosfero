Feature: language redirection
  As a guest
  I want to see an article

  Background:
    Given the following users
      | login  | name         |
      | manuel | Manuel Silva |
    And the following articles
      | owner  | name       | body            | language | translation_of |
      | manuel | Meu Artigo | isso é um teste | pt   | nil            |
      | manuel | My Article | this is a test  | en   | Meu Artigo     |

  Scenario: view page in Pt as Pt guest
    Given my browser prefers Portuguese
    When I go to /manuel/meu-artigo
    Then the site should be in Portuguese

  Scenario: view page in Pt as En guest with redirection disabled by default
    Given my browser prefers English
    When I go to /manuel/meu-artigo
    Then the site should be in Portuguese

  Scenario: view page in Pt as En guest with redirection enabled
    #Given manuel enabled translation redirection in his profile
    # Testing the web UI
    Given I am logged in as "manuel"
    And my browser prefers English
    And I go to /myprofile/manuel/profile_editor/edit
    And I check "Automaticaly redirect the visitor to the article translated to his/her language"
    And I press "Save"
    When I go to /manuel/meu-artigo
    Then the site should be in English

  Scenario: view page in Pt as En guest with redirection disabled
    Given manuel disabled translation redirection in his profile
    And my browser prefers English
    When I go to /manuel/meu-artigo
    Then the site should be in Portuguese

