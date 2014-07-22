Feature: upload files
  As a logged user
  I want to upload files

  Background:
    Given the following users
      | login | name |
      | joaosilva | Joao Silva |
    And I am logged in as "joaosilva"

  Scenario: provile links to upload files to community's gallery
    Given the following communities
      | identifier | name | owner |
      | sample-community | Sample Community | joaosilva |
    And the following galleries
      | owner | name |
      | sample-community | Gallery test |
    And I go to article "Gallery test"
    Then I should see "Upload files"

  Scenario: provile links to upload files to enterprise's gallery
    Given the following enterprises
      | identifier | name | owner |
      | sample-enterprise | Sample Enterprise | joaosilva |
    And the following galleries
      | owner | name |
      | sample-enterprise | Gallery test |
    And I go to article "Gallery test"
    Then I should see "Upload files"

  Scenario: not provile links to upload files on blogs
    Given the following communities
      | identifier | name | owner |
      | sample-community | Sample Community | joaosilva |
    And the following blogs
      | owner | name |
      | sample-community | Blog test |
    And I go to Sample Community's blog
    And I should not see "Upload files"
