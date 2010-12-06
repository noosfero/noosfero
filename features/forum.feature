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

  Scenario: create a forum
    Given I go to the Control panel
    And I follow "Manage Content"
    When I follow "New Forum"
    And I fill in "Title" with "My Forum"
    And I press "Save"
    Then I should see "Configure forum"

  Scenario: redirect to forum after create forum from cms
    Given I go to the Control panel
    And I follow "Manage Content"
    When I follow "New Forum"
    And I fill in "Title" with "Forum from cms"
    And I press "Save"
    Then I should be on /joaosilva/forum-from-cms

  Scenario: create multiple forums
    Given I go to the Control panel
    And I follow "Manage Content"
    And I follow "New Forum"
    And I fill in "Title" with "Forum One"
    And I press "Save"
    Then I go to the Control panel
    And I follow "Manage Content"
    And I follow "New Forum"
    And I fill in "Title" with "Forum Two"
    And I press "Save"
    Then I should not see "error"
    And I should be on /joaosilva/forum-two

  Scenario: cancel button back to cms
    Given I go to the Control panel
    And I follow "Manage Content"
    And I follow "New Forum"
    When I follow "Cancel" within ".main-block"
    Then I should be on /myprofile/joaosilva/cms

  Scenario: cancel button back to myprofile
    Given I go to the Control panel
    And I follow "Manage Content"
    And I follow "New Forum"
    When I follow "Cancel" within ".main-block"
    Then I should be on /myprofile/joaosilva/cms

  Scenario: configure forum when viewing it
    Given the following forums
       | owner     | name     |
       | joaosilva | Forum One |
    And I go to /joaosilva/forum-one
    When I follow "Configure forum"
    Then I should be on edit "Forum One" by joaosilva
