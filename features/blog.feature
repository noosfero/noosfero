Feature: blog
  As a noosfero user
  I want to have one or mutiple blogs

  Background:
    Given I am on the homepage
    And the following users
      | login | name |
      | joaosilva | Joao Silva |
    And "joaosilva" has no articles
    And I am logged in as "joaosilva"

  Scenario: create a blog
    Given I go to the Control panel
    And I follow "Create blog"
    Then I should see "My Blog"
    When I fill in "Title" with "My Blog"
    And I press "Save"
    And I go to Joao Silva's control panel
    Then I should see "Configure blog"

  Scenario: redirect to blog after create blog from control panel
    Given I go to the Control panel
    And I follow "Create blog"
    Then I should see "My Blog"
    When I fill in "Title" with "My Blog"
    And I press "Save"
    Then I should be on /joaosilva/my-blog

  Scenario: redirect to blog after create blog from cms
    Given I go to the Control panel
    And I follow "Manage Content"
    When I follow "New Blog"
    And I fill in "Title" with "Blog from cms"
    And I press "Save"
    Then I should be on /joaosilva/blog-from-cms

  Scenario: create multiple blogs
    Given I go to the Control panel
    And I follow "Manage Content"
    And I follow "New Blog"
    And I fill in "Title" with "Blog One"
    And I press "Save"
    Then I go to the Control panel
    And I follow "Manage Content"
    And I follow "New Blog"
    And I fill in "Title" with "Blog Two"
    And I press "Save"
    Then I should not see "error"
    And I should be on /joaosilva/blog-two

  Scenario: cancel button back to cms
    Given I go to the Control panel
    And I follow "Manage Content"
    And I follow "New Blog"
    When I follow "Cancel" within ".main-block"
    Then I should be on /myprofile/joaosilva/cms

  Scenario: cancel button back to myprofile
    Given I go to the Control panel
    And I follow "Create blog"
    When I follow "Cancel" within ".main-block"
    Then I should be on /myprofile/joaosilva

  Scenario: configure blog link to cms
    Given the following blogs
      | owner     | name     |
      | joaosilva | Blog One |
      | joaosilva | Blog Two |
    And I go to the Control panel
    When I follow "Configure blog"
    Then I should be on /myprofile/joaosilva/cms

  Scenario: configure blog link to edit blog
    Given the following blogs
       | owner     | name     |
       | joaosilva | Blog One |
    And I go to the Control panel
    When I follow "Configure blog"
    Then I should be on edit "Blog One" by joaosilva

  Scenario: configure blog when viewing it
    Given the following blogs
       | owner     | name     |
       | joaosilva | Blog One |
    And I go to /joaosilva/blog-one
    When I follow "Configure blog"
    Then I should be on edit "Blog One" by joaosilva

  Scenario: change address of blog
    Given the following blogs
      | owner     | name     |
      | joaosilva | Blog One |
    And I go to the Control panel
    And I follow "Configure blog"
    And I fill in "Address" with "blog-two"
    And I press "Save"
    When I am on /joaosilva/blog-two
    Then I should see "Blog One"

  Scenario: display tag list field when creating new blog
    Given I go to the Control panel
    And I follow "Manage Content"
    When I follow "New blog"
    Then I should see "Tag list"
