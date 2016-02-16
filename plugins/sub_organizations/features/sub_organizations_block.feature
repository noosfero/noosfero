Feature: related_organizations_block
  As a user
  I want my organizations to have blocks that lists it's related-organizations
  In order to have quick access to it's related-organizations

  Background:
    Given "SubOrganizations" plugin is enabled
    And the following users
      | login | name |
      | homer | Homer |
    And the following community
      | identifier | name | owner |
      | springfield | Springfield | homer |
      | moe | Moe | homer |
    And the following enterprise
      | identifier | name | owner |
      | duff | Duff | homer |
    And "moe" is a sub organization of "springfield"
    And "duff" is a sub organization of "springfield"
    And I am logged in as "homer"
    And I go to springfield's control panel

  Scenario: display both sub types on block
    Given the following blocks
      | owner | type |
      | springfield | RelatedOrganizationsBlock |
    When I follow "Edit sideboxes"
    Then I should see "Moe" within ".block.related-organizations-block"
    And I should see "Duff" within ".block.related-organizations-block"

  Scenario: display only sub-communities
    Given the following blocks
      | owner | type |
      | springfield | RelatedOrganizationsBlock |
    When I follow "Edit sideboxes"
    And I follow "Edit" within ".block.related-organizations-block"
    And I select "Community" from "block_organization_type"
    And I press "Save"
    Then I should see "Moe" within ".block.related-organizations-block"
    And I should not see "Duff" within ".block.related-organizations-block"

  Scenario: display both sub types on sub-organizations page
    When I go to springfield's "children" page from "SubOrganizationsPluginProfileController" of "SubOrganizations" plugin
    Then I should see "Moe"
    And I should see "Duff"

  Scenario: display only sub-communities on sub-organizations page
    Given the following blocks
      | owner | type |
      | springfield | RelatedOrganizationsBlock |
    When I follow "Edit sideboxes"
    And I follow "Edit" within ".block.related-organizations-block"
    And I select "Community" from "block_organization_type"
    And I press "Save"
    And I follow "View all" within ".block.related-organizations-block"
    Then I should see "Moe" within ".profile-list"
    And I should not see "Duff" within ".profile-list"
