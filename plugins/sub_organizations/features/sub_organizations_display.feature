Feature: sub_organizations_display
  As a user
  I want my organizations to have blocks that lists it's related-organizations
  In order to have quick access to it's related-organizations

   Background:
   Given "SubOrganizations" plugin is enabled
    And the following users
      | login | name |
      | nelson | Nelson |
   And feature "enterprise_registration" is enabled on environment
   And the following community
      | identifier  | name        | owner  | description             | city        | state      |
      | springfield | Springfield | nelson | Springfield description | Los Angeles | California |
      | moe         | Moe         | nelson | Moe description         | Kansas      | Texas      |
   And the following enterprise
      | identifier | name   |  owner | description        | city           | state      |
      | school     | School | nelson | School description | Terra do Nunca | Billy Jean |
   And I am logged in as "nelson"
   And I go to springfield's control panel
   When I follow "Edit sideboxes"
   And I follow "Add a block"
   And I choose "Related Organizations"
   And I press "Add"

    @selenium
    Scenario: Display the sub organization block when there is a sub enterprise and communitys
      When I go to springfield's control panel
      And I follow "Manage sub-groups"
      And I follow "Register a new sub-enterprise"
      And I fill in "Name" with "Bart"
      And I fill in "Address" with "bart"
      And I press "Next"
      Then I should see "Enterprise registration completed"
      And I am logged in as admin
      And I go to admin_user's control panel
      When I follow "Tasks" within ".control-panel"
      Then I should see "Nelson wants to create enterprise Bart."
      And the first mail is to admin_user@example.com
      And I choose "Accept"
      And I press "Apply!"
      And I am logged in as "nelson"
      When I go to springfield's control panel
      And I follow "Manage sub-groups"
      And I follow "Create a new sub-community"
      And I fill in "Name" with "Homer"
      And I press "Create"
      When I go to springfield's "children" page from "SubOrganizationsPluginProfileController" of "SubOrganizations" plugin
      Then I should see "Homer" within ".related-organizations-block"
      And I should see "Bart" within ".related-organizations-block"

    Scenario: Display with compact mode
      Given "moe" is a sub organization of "springfield"
      And "school" is a sub organization of "springfield"
      When I go to springfield's homepage
      And I follow "View all" within ".related-organizations-block"
      Then I should see "Springfield's sub-communities"
      And I should see "Springfield's sub-enterprises"

    Scenario: Display with full mode for sub-communities
      Given "moe" is a sub organization of "springfield"
      When I go to springfield's homepage
      And I follow "View all" within ".related-organizations-block"
      Then I should see "Springfield's sub-communities"
      And I follow "Full" within ".search-customize-options"
      Then I should see "Moe description" within ".related-organizations-description"
      And I should see "Kansas, Texas" within ".related-organizations-region-name"

    Scenario: Display with full mode for sub-enterprises
      Given "school" is a sub organization of "springfield"
      When I go to springfield's homepage
      And I follow "View all" within ".related-organizations-block"
      And I should see "Springfield's sub-enterprises"
      And I follow "Full" within ".search-customize-options"
      Then I should see "School description" within ".related-organizations-description"
      And I should see "Terra do Nunca, Billy Jean" within ".related-organizations-region-name"

    Scenario: Display message when display full block are empty
      Given I follow "View all" within ".related-organizations-block"
      Then I should see "There are no sub-communities yet."
      And I should see "There are no sub-enterprises yet."
