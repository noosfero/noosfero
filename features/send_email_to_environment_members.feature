Feature: send emails to environment members users
  As an administrator
  I want to send email to all users

  Scenario: Cant access if not logged in
    Given I am not logged in
    When I go to /admin/users/send_mail
    Then I should be on login page

  Scenario: Cant access as normal user
    Given the following user
      | login |
      | ultraje |
    And I am logged in as "ultraje"
    When I go to /admin/users/send_mail
    Then I should see "Access denied"

  Scenario: Send e-mail to members
    Given I am logged in as admin
    And I go to /admin/users/send_mail
    And I fill in "Subject" with "Hello, user!"
    And I fill in "Body" with "We have some news"
    When I press "Send"
    Then I should be on /admin/users

  Scenario: Not send e-mail to members if subject is blank
    Given I am logged in as admin
    And I go to /admin/users/send_mail
    And I fill in "Body" with "We have some news"
    When I press "Send"
    Then I should be on /admin/users/send_mail

  Scenario: Not send e-mail to members if body is blank
    Given I am logged in as admin
    And I go to /admin/users/send_mail
    And I fill in "Subject" with "Hello, user!"
    When I press "Send"
    Then I should be on /admin/users/send_mail

  Scenario: Cancel creation of mailing
    Given I am logged in as admin
    And I go to /admin/users/send_mail
    Then I should be on /admin/users/send_mail
    When I follow "Cancel e-mail"
    Then I should be on /admin/users

  Scenario: Should display recipients options
    Given I am logged in as admin
    And I go to /admin/users/send_mail
    Then I should see "Recipients"
    Then I should see "All Users"
    Then I should see "Only Admins"
    Then I should see "Environment Admins"
    Then I should see "Profile Admins"

  Scenario: All users should be marked as default recipients
    Given I am logged in as admin
    And I go to /admin/users/send_mail
    Then the "send_to_all" radio button should be checked
    Then the "send_to_admins" radio button should not be checked

  @selenium
  Scenario: Should disable checkboxes when recipients is set to All users
    Given I am logged in as admin
    And I go to /admin/users/send_mail
    Then the field "#profile_admins" should be disabled
    Then the field "#env_admins" should be disabled
    When I choose "Only Admins"
    Then the field "#profile_admins" should be enabled
    Then the field "#env_admins" should be enabled

