Feature: change organization name
  As an organization's admin
  I want to change it's name
  In order to keep it's name consistent

  Scenario: changing community's name
    Given the following communities
      | identifier | name |
      | sample-community | Sample Community |
    And the following users
      | login | name |
      | joaosilva | Joao Silva |
    And "Joao Silva" is admin of "Sample Community"
    And I am logged in as "joaosilva"
    And I am on Sample Community's control panel
    And I follow "Community Info and settings"
    And I fill in "Name" with "New Sample Community"
    When I press "Save"
    Then I should be on New Sample Community's control panel


  Scenario: changing enterprise's name
    Given the following enterprises
      | identifier | name |
      | sample-enterprise | Sample Enterprise |
    And the following users
      | login | name |
      | joaosilva | Joao Silva |
    And "Joao Silva" is admin of "Sample Enterprise"
    And I am logged in as "joaosilva"
    And I am on Sample Enterprise's control panel
    And I follow "Enterprise Info and settings"
    And I fill in "Name" with "New Sample Enterprise"
    When I press "Save"
    Then I should be on New Sample Enterprise's control panel
