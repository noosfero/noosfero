Feature:
  In order to enter in a community
  As a logged user
  I want to enter in a community by 'join leave' button in members block

  Background:
    Given the following users
      | login      | name        |
      | joaosilva  | Joao Silva  |
      | mariasilva | Maria Silva |

  Scenario: a user can join in a community by members block's button
    Given the following communities
      | owner     | identifier        | name              |
      | joaosilva | sample-community  | Sample Community  |
    And the following blocks
      | owner            | type         | show_join_leave_button |
      | sample-community | MembersBlock |        true            |
    And I am logged in as "mariasilva"
    And I go to sample-community's homepage
    When I follow "Join this community" within ".members-block"
    And I go to mariasilva's control panel
    And I follow "Groups" within "#section-relationships"
    Then I should see "Sample Community"

  Scenario: a not logged in user can log in by members block's button
    Given the following communities
      | owner     | identifier        | name              |
      | joaosilva | sample-community  | Sample Community  |
    And the following blocks
      | owner            | type         | show_join_leave_button |
      | sample-community | MembersBlock |        true            |
    And I am not logged in
    When I go to sample-community's homepage
    And I follow "Join this community" within ".members-block"
    Then I should see "Username / Email"

  Scenario: the join-leave button do not appear if the checkbox show-join-leave-button is not checked
    Given the following communities
      | owner     | identifier        | name              |
      | joaosilva | sample-community  | Sample Community  |
    And the following blocks
      | owner            | type         | show_join_leave_button |
      | sample-community | MembersBlock |        false           |
    When I go to sample-community's homepage
    Then I should not see "Join this community" within ".members-block"
    And I should not see "Leave community" within ".members-block"
