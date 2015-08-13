Feature:
  In order to enter in a community
  As a logged user
  I want to enter in a community by 'join leave' button in members block

  Background:
    Given the following users
      | login      | name        |
      | joaosilva  | Joao Silva  |
      | mariasilva | Maria Silva |
    And the following communities
      | owner     | identifier        | name              |
      | joaosilva | sample-community  | Sample Community  |
    And the following blocks
      | owner            | type         |
      | sample-community | MembersBlock |
    And I am logged in as "joaosilva"
    And I go to sample-community's control panel
    And I follow "Edit sideboxes"
    And I follow "Edit" within ".members-block"
    And I check "Show join leave button"
    And I press "Save"

  Scenario: a user can join in a community by members block's button
    Given I am logged in as "mariasilva"
    And I go to sample-community's homepage
    When I follow "Join this community" within ".members-block"
    And I go to mariasilva's control panel
    And I follow "Manage my groups"
    Then I should see "Sample Community"

  @selenium
  Scenario: a user can leave a community by members block's button
    Given "Maria Silva" is a member of "Sample Community"
    And I am logged in as "mariasilva"
    When I go to sample-community's homepage
    And I follow "Leave community" within ".members-block"
    And I go to mariasilva's control panel
    And I follow "Manage my groups"
    Then I should not see "Sample Community"

  Scenario: a not logged in user can log in by members block's button
    Given I am not logged in
    When I go to sample-community's homepage
    And I follow "Join this community" within ".members-block"
    Then I should see "Username / Email"

  Scenario: the join-leave button do not appear if the checkbox show-join-leave-button is not checked
    And I go to sample-community's control panel
    And I follow "Edit sideboxes"
    And I follow "Edit" within ".members-block"
    And I uncheck "Show join leave button"
    And I press "Save"
    When I go to sample-community's homepage
    Then I should not see "Join this community" within ".members-block"
    And I should not see "Leave community" within ".members-block"
