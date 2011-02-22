Feature: send emails to environment members users
  As an administrator
  I want to send email to all users

  Scenario: Cant access if not logged in
    Given I am not logged in
    When I go to /admin/users/send_mail
    Then I should see "Access denied"

  Scenario: Cant access as normal user
    Given the following user
      | login |
      | ultraje |
    And I am logged in as "ultraje"
    When I go to /admin/users/send_mail
    Then I should see "Access denied"

  Scenario: Send e-mail to members
    Given I am logged in as admin
    When I follow "Administration"
    And I follow "Manage users"
    And I follow "Send e-mail to users"
    And I fill in "Subject" with "Hello, user!"
    And I fill in "body" with "We have some news"
    When I press "Send"
    Then I should be on /admin/users

  Scenario: Not send e-mail to members if subject is blank
    Given I am logged in as admin
    When I follow "Administration"
    And I follow "Manage users"
    And I follow "Send e-mail to users"
    And I fill in "body" with "We have some news"
    When I press "Send"
    Then I should be on /admin/users/send_mail

  Scenario: Not send e-mail to members if body is blank
    Given I am logged in as admin
    When I follow "Administration"
    And I follow "Manage users"
    And I follow "Send e-mail to users"
    And I fill in "Subject" with "Hello, user!"
    When I press "Send"
    Then I should be on /admin/users/send_mail

  Scenario: Cancel creation of mailing
    Given I am logged in as admin
    When I follow "Administration"
    And I follow "Manage users"
    And I follow "Send e-mail to users"
    Then I should be on /admin/users/send_mail
    When I follow "Cancel e-mail"
    Then I should be on /admin/users
