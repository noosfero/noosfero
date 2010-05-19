Feature: invitation
  As a noosfero visitor
  I want to invite my friends to Noosfero

  Background:
    Given the following users
      | login      | email             |
      | josesilva  | silva@invalid.br  |
      | josesantos | santos@invalid.br |
    And the following communities
      | owner     | identifier  | name        |
      | josesilva | 26-bsslines | 26 Bsslines |
    And the following enterprises
      | owner     | identifier       | name             |
      | josesilva | beatles-for-sale | Beatles For Sale |
    And I am logged in as "josesilva"

  Scenario: see link to invite friends
    When I am on /profile/josesilva/friends
    Then I should see "Invite people from my e-mail contacts" link

  Scenario: see link to invite friends in myprofile
    When I am on /myprofile/josesilva/friends
    Then I should see "Invite people from my e-mail contacts" link

  Scenario: go to invitation screen when follow link to invite friends
    Given I am on /myprofile/josesilva/friends
    When I follow "Invite people from my e-mail contacts"
    Then I am on /profile/josesilva/invite/friends

  Scenario: see title when invite friends
    When I am on /profile/josesilva/invite/friends
    Then I should see "Invite your friends"

  # why not work?
  Scenario: back to manage friends after invite friends
    Given I am on /myprofile/josesilva/friends
    And I follow "Invite people from my e-mail contacts"
    And I press "Next"
    And I fill in "manual_import_addresses" with "misfits@devil.doll"
    And I fill in "mail_template" with "Follow this link <url>"
    When I press "Invite my friends!"
    Then I should be on /myprofile/josesilva/friends

  Scenario: see link to invite members to community
    When I am on /profile/26-bsslines/members
    Then I should see "Invite your friends to join 26 Bsslines" link

  Scenario: not see link to invite members to community if has no rights
    Given I am not logged in
    And I am logged in as "josesantos"
    When I am on /profile/26-bsslines/members
    Then I should not see "Invite your friends to join 26 Bsslines" link

  Scenario: go to invitation screen when follow link to invite members
    Given I am on /profile/26-bsslines/members
    When I follow "Invite your friends to join 26 Bsslines"
    Then I am on /profile/26-bsslines/invite/friends

  Scenario: see title when invite members
    When I am on /profile/26-bsslines/invite/friends
    Then I should see "Invite your friends to join 26 Bsslines"

  Scenario: not see link to invite members to enterprise
    When I am on /profile/beatles-for-sale/members
    Then I should not see "Invite your friends to join Beatles For Sale" link

  Scenario: deny access if user has no right to invite members
    Given I am not logged in
    And I am logged in as "josesantos"
    When I am on /profile/26-bsslines/invite/friends
    Then I should see "Access denied"

  Scenario: not see link to invite members to enterprise in manage members
    Given I am on Beatles For Sale's members management
    Then I should not see "Invite your friends to join Beatles For Sale" link

  Scenario: back to manage members after invite friends
    Given I am on 26 Bsslines's members management
    And I follow "Invite your friends to join 26 Bsslines"
    And I press "Next"
    And I fill in "manual_import_addresses" with "misfits@devil.doll"
    And I fill in "mail_template" with "Follow this link <url>"
    When I press "Invite my friends!"
    Then I should be on /myprofile/26-bsslines/profile_members

  Scenario: noosfero user receives a task when a user invites to join a community
    Given I am on 26 Bsslines's members management
    And I follow "Invite your friends to join 26 Bsslines"
    And I press "Next"
    And I fill in "manual_import_addresses" with "santos@invalid.br"
    And I fill in "mail_template" with "Follow this link <url>"
    And I press "Invite my friends!"
    When I am logged in as "josesantos"
    And I follow "Control Panel"
    And I should see "josesilva invites you to join the community 26 Bsslines."

  Scenario: noosfero user accepts to join community
    Given I invite email "santos@invalid.br" to join community "26 Bsslines"
    When I am logged in as "josesantos"
    And I follow "Control panel"
    And I follow "Process requests"
    And I should see "josesilva invites you to join the community 26 Bsslines."
    And I choose "Accept"
    When I press "Ok!"
    Then I should not see "josesilva invites you to join the community 26 Bsslines."
    When I follow "Control panel"
    And I follow "Manage my groups"
    Then I should see "26 Bsslines"

  Scenario: noosfero user rejects to join community
    Given I invite email "santos@invalid.br" to join community "26 Bsslines"
    When I am logged in as "josesantos"
    And I follow "Control panel"
    And I follow "Process requests"
    And I should see "josesilva invites you to join the community 26 Bsslines."
    And I choose "Reject"
    When I press "Ok!"
    Then I should not see "josesilva invites you to join the community 26 Bsslines."
    When I follow "Control panel"
    And I follow "Manage my groups"
    Then I should not see "26 Bsslines"

  Scenario: noosfero user receives a task when a user invites to be friend
    Given I am on josesilva's control panel
    And I follow "Manage Friends"
    And I follow "Invite people from my e-mail contacts"
    And I press "Next"
    And I fill in "manual_import_addresses" with "santos@invalid.br"
    And I fill in "mail_template" with "Follow this link <url>"
    And I press "Invite my friends!"
    When I am logged in as "josesantos"
    And I follow "Control Panel"
    And I should see "josesilva wants to be your friend."

  Scenario: noosfero user accepts to be friend
    Given I invite email "santos@invalid.br" to be my friend
    When I am logged in as "josesantos"
    And I follow "Control panel"
    And I follow "Process requests"
    And I should see "josesilva wants to be your friend."
    And I choose "Accept"
    When I press "Ok!"
    And I should not see "josesilva wants to be your friend."
    When I follow "Control panel"
    And I follow "Manage friends"
    Then I should see "josesilva"

  Scenario: noosfero user rejects to be friend
    Given I invite email "santos@invalid.br" to be my friend
    When I am logged in as "josesantos"
    And I follow "Control panel"
    And I follow "Process requests"
    And I should see "josesilva wants to be your friend."
    And I choose "Ignore"
    When I press "Ok!"
    And I should not see "josesilva wants to be your friend."
    When I follow "Control panel"
    And I follow "Manage friends"
    Then I should not see "josesilva"
