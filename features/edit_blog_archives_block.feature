Feature: edit_blog_archives_block
  As a blog owner
  I want to edit a Blog Archive Block

  Scenario: not offer to select blog when I have once blog
    Given I am on the homepage
    And the following users
      | login | name |
      | joaosilva | Joao Silva |
    And the following blogs
      | owner     | name     |
      | joaosilva | Blog One |
    And the following blocks
      | owner     | type             |
      | joaosilva | BlogArchivesBlock |
    And I am logged in as "joaosilva"
    When I go to edit BlogArchivesBlock of joaosilva
    Then I should not see "Choose a blog:"

  Scenario: offer to select blog when I have multiple blogs
    Given I am on the homepage
    And the following users
      | login | name |
      | joaosilva | Joao Silva |
    And the following blogs
      | owner     | name     |
      | joaosilva | Blog One |
      | joaosilva | Blog Two |
    And the following blocks
      | owner     | type             |
      | joaosilva | BlogArchivesBlock |
    And I am logged in as "joaosilva"
    When I go to edit BlogArchivesBlock of joaosilva
    Then I should see "Choose a blog:"
