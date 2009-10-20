Feature: blog
  As a noosfero user
  I want to have one or mutiple blogs

  Background:
    Given I am on the homepage
    And the following users
      | login | name |
      | joaosilva | Joao Silva |
    And I am logged in as "joaosilva"

  Scenario: create a blog
    Given I follow "Control panel"
    And I follow "Create blog"
    Then I should see "My Blog"
    When I fill in "Title" with "My Blog"
    And I press "Save"
    And I follow "Control panel"
    Then I should see "Configure blog"

  Scenario: redirect to control panel after create blog
    Given I follow "Control panel"
    And I follow "Create blog"
    Then I should see "My Blog"
    When I fill in "Title" with "My Blog"
    And I press "Save"
    Then I should be on /myprofile/joaosilva

  Scenario: redirect to cms after create blog
    Given I follow "Control panel"
    And I follow "Manage Content"
    When I follow "New Blog"
    Then I should see "My Blog"
    When I fill in "Title" with "My Blog"
    And I press "Save"
    Then I should be on /myprofile/joaosilva/cms

  Scenario: create multiple blogs
    Given I follow "Control panel"
    And I follow "Manage Content"
    And I follow "New Blog"
    And I fill in "Title" with "Blog One"
    And I press "Save"
    And I follow "New Blog"
    And I fill in "Title" with "Blog Two"
    And I press "Save"
    Then I should not see "error"
    And I should be on /myprofile/joaosilva/cms

  Scenario: cancel button back to cms
    Given I follow "Control panel"
    And I follow "Manage Content"
    And I follow "New Blog"
    When I follow "Cancel"
    Then I should be on /myprofile/joaosilva/cms

  Scenario: cancel button back to myprofile
    Given I follow "Control panel"
    And I follow "Create blog"
    When I follow "Cancel"
    Then I should be on /myprofile/joaosilva

  Scenario: configure blog link to cms
    Given the following blogs
      | owner     | name     |
      | joaosilva | Blog One |
      | joaosilva | Blog Two |
    And I follow "Control panel"
    When I follow "Configure blog"
    Then I should be on /myprofile/joaosilva/cms

  Scenario: configure blog link to edit blog
    Given the following blogs
       | owner     | name     |
       | joaosilva | Blog One |
    And I follow "Control panel"
    When I follow "Configure blog"
    Then I should be on edit "Blog One" by joaosilva

  Scenario: change address of blog
    Given the following blogs
      | owner     | name     |
      | joaosilva | Blog One |
    And I follow "Control panel"
    And I follow "Configure blog"
    And I fill in "Address" with "blog-two"
    And I press "Save"
    When I am on /joaosilva/blog-two
    Then I should see "Blog One"
