Feature: send emails to organization members
  As a organization administrator or moderator
  I want to send email to all members

  Background:
    Given the following users
      | login | name |
      | joaosilva | Joao Silva |
      | jose | Jose Silva |
      | manoel | Manoel Silva |
    And the following communities
      | identifier | name |
      | sample-community | Sample Community |
    And "Joao Silva" is admin of "Sample Community"
    And "Jose Silva" is moderator of "Sample Community"
    And "Manoel Silva" is a member of "Sample Community"

  Scenario: Cant access if not logged in
    Given I am not logged in
    When I go to /profile/sample-community/send_mail
    Then I should be on login page

  Scenario: Cant access as normal user
    Given the following user
      | login |
      | josesilva |
    And I am logged in as "josesilva"
    When I go to /profile/sample-community/send_mail
    Then I should see "Access denied"

  Scenario: Send e-mail to members
    Given I am logged in as "joaosilva"
    And I go to Sample Community's members management
    And I check "checkbox-manoel"
    And I press "Send e-mail to members"
    And I fill in "Subject" with "Hello, member!"
    And I fill in "Body" with "We have some news"
    When I press "Send"
    Then I should be on Sample Community's members management

  Scenario: Not send e-mail to members if subject is blank
    Given I am logged in as "joaosilva"
    And I go to Sample Community's members management
    And I check "checkbox-manoel"
    And I press "Send e-mail to members"
    And I fill in "Body" with "We have some news"
    When I press "Send"
    Then I should be on /profile/sample-community/send_mail

  Scenario: Not send e-mail to members if body is blank
    Given I am logged in as "joaosilva"
    And I go to Sample Community's members management
    And I check "checkbox-manoel"
    And I press "Send e-mail to members"
    And I fill in "Subject" with "Hello, user!"
    When I press "Send"
    Then I should be on /profile/sample-community/send_mail

  Scenario: Cancel creation of mailing
    Given I am logged in as "joaosilva"
    And I go to Sample Community's members management
    And I check "checkbox-manoel"
    And I press "Send e-mail to members"
    When I follow "Cancel e-mail"
    Then I should be on Sample Community's members management

  Scenario: Cant access if has no send_mail_to_members permission
    Given I am logged in as "manoel"
    When I go to /profile/sample-community/send_mail
    Then I should see "Access denied"

  Scenario: Show button "Send e-Mail to members" of community to an moderator
    Given I am logged in as "jose"
    When I go to Sample Community's members page
    Then I should see "Send e-mail to members"

  Scenario: Not show button "Send e-Mail to members" if user has no right permission
    Given I am logged in as "manoel"
    When I go to Sample Community's members page
    Then I should not see "Send e-mail to members"

  Scenario: Redirect back to profile members page after send mail
    Given I am logged in as "jose"
    When I go to Sample Community's members page
    And I follow "Send e-mail to members"
    And I fill in "Subject" with "Hello, member!"
    And I fill in "Body" with "We have some news"
    When I press "Send"
    Then I should be on Sample Community's members page

  Scenario: Back to profile members page after cancel creation of mailing
    Given I am logged in as "jose"
    And I go to Sample Community's members page
    And I follow "Send e-mail to members"
    When I follow "Cancel e-mail"
    Then I should be on Sample Community's members page
