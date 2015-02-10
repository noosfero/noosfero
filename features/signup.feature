Feature: signup
  As a new user
  I want to sign up to the site
  So I can have fun using its features

  @selenium
  Scenario: successfull registration
    Given I am on the homepage
    When I follow "Login"
    And I follow "New user"
    And I fill in the following within ".no-boxes":
      | e-Mail                | josesilva@example.com |
      | Username              | josesilva             |
      | Password              | secret                |
      | Password confirmation | secret                |
      | Full name             | José da Silva         |
    And wait for the captcha signup time
    And I press "Create my account"
    Then I should receive an e-mail on josesilva@example.com
    When I go to login page
    And I fill in "Username" with "josesilva"
    And I fill in "Password" with "secret"
    And I press "Log in"
    Then I should not be logged in as "josesilva"
    When José da Silva's account is activated
    And I go to login page
    And I fill in "Username" with "josesilva"
    And I fill in "Password" with "secret"
    And I press "Log in"
    Then I should be logged in as "josesilva"

  @selenium
  Scenario: show error message if username is already used
    Given the following users
      | login     |
      | josesilva |
    When I go to signup page
    And I fill in "Username" with "josesilva"
    And I fill in "e-Mail" with "josesilva1"
    Then I should see "This login name is unavailable"

  Scenario: be redirected if user goes to signup page and is logged
    Given the following users
      | login | name |
      | joaosilva | joao silva |
    Given I am logged in as "joaosilva"
    And I go to signup page
    Then I should be on joaosilva's control panel

  @selenium
  Scenario: user cannot register without a name
    Given I am on the homepage
    And I follow "Login"
    And I follow "New user"
    And I fill in "e-Mail" with "josesilva@example.com"
    And I fill in "Username" with "josesilva"
    And I fill in "Password" with "secret"
    And I fill in "Password confirmation" with "secret"
    And wait for the captcha signup time
    And I press "Create my account"
    Then I should see "Name can't be blank"

  Scenario: user cannot change his name to empty string
    Given the following users
      | login | name |
      | joaosilva | Joao Silva |
    Given I am logged in as "joaosilva"
    And I am on joaosilva's control panel
    And I follow "Edit Profile"
    And I fill in "Name" with ""
    When I press "Save"
    Then I should see "Name can't be blank"

  @selenium
  Scenario: user should stay on same page after signup
    Given the environment is configured to stay on the same page after signup
    And feature "skip_new_user_email_confirmation" is enabled on environment
    And I am on /search/people
    When I follow "Sign up"
    And I fill in the following within ".no-boxes":
      | e-Mail                | josesilva@example.com |
      | Username              | josesilva             |
      | Password              | secret                |
      | Password confirmation | secret                |
      | Full name             | José da Silva         |
    And wait for the captcha signup time
    And I press "Create my account"
    Then I should be on /search/people

  @selenium
  Scenario: user should go to his homepage after signup
    Given the environment is configured to redirect to profile homepage after signup
    And feature "skip_new_user_email_confirmation" is enabled on environment
    And I am on /search/people
    When I follow "Sign up"
    And I fill in the following within ".no-boxes":
      | e-Mail                | josesilva@example.com |
      | Username              | josesilva             |
      | Password              | secret                |
      | Password confirmation | secret                |
      | Full name             | José da Silva         |
    And wait for the captcha signup time
    And I press "Create my account"
    Then I should be on josesilva's profile

  @selenium
  Scenario: user should go to his control panel after signup
    Given the environment is configured to redirect to profile control panel after signup
    And feature "skip_new_user_email_confirmation" is enabled on environment
    And I am on /search/people
    When I follow "Sign up"
    And I fill in the following within ".no-boxes":
      | e-Mail                | josesilva@example.com |
      | Username              | josesilva             |
      | Password              | secret                |
      | Password confirmation | secret                |
      | Full name             | José da Silva         |
    And wait for the captcha signup time
    And I press "Create my account"
    Then I should be on josesilva's control panel

  @selenium
  Scenario: user should go to his profile page after signup
    Given the environment is configured to redirect to user profile page after signup
    And feature "skip_new_user_email_confirmation" is enabled on environment
    And I am on /search/people
    When I follow "Sign up"
    And I fill in the following within ".no-boxes":
      | e-Mail                | josesilva@example.com |
      | Username              | josesilva             |
      | Password              | secret                |
      | Password confirmation | secret                |
      | Full name             | José da Silva         |
    And wait for the captcha signup time
    And I press "Create my account"
    Then I should be on josesilva's profile

  @selenium
  Scenario: user should go to the environment's homepage after signup
    Given the environment is configured to redirect to site homepage after signup
    And feature "skip_new_user_email_confirmation" is enabled on environment
    And I am on /search/people
    When I follow "Sign up"
    And I fill in the following within ".no-boxes":
      | e-Mail                | josesilva@example.com |
      | Username              | josesilva             |
      | Password              | secret                |
      | Password confirmation | secret                |
      | Full name             | José da Silva         |
    And wait for the captcha signup time
    And I press "Create my account"
    Then I should be on the homepage

  @selenium
  Scenario: user should go to the environment's welcome page after signup
    Given the environment is configured to redirect to welcome page after signup
    And I am on /search/people
    When I follow "Sign up"
    And I fill in the following within ".no-boxes":
      | e-Mail                | josesilva@example.com |
      | Username              | josesilva             |
      | Password              | secret                |
      | Password confirmation | secret                |
      | Full name             | José da Silva         |
    And wait for the captcha signup time
    And I press "Create my account"
    Then I should be on the welcome page

  @selenium
  Scenario: user should stay on same page after following confirmation link
    Given the environment is configured to stay on the same page after login
    And feature "skip_new_user_email_confirmation" is disabled on environment
    And I am on /search/people
    When I follow "Sign up"
    And I fill in the following within ".no-boxes":
      | e-Mail                | josesilva@example.com |
      | Username              | josesilva             |
      | Password              | secret                |
      | Password confirmation | secret                |
      | Full name             | José da Silva         |
    And wait for the captcha signup time
    And I press "Create my account"
    And I go to josesilva's confirmation URL
    And I fill in "Username" with "josesilva"
    And I fill in "Password" with "secret"
    And I press "Log in"
    Then I should be on /search/people

  @selenium
  Scenario: user should go to his homepage after following confirmation link
    Given the environment is configured to redirect to profile homepage after login
    And feature "skip_new_user_email_confirmation" is disabled on environment
    And I am on /search/people
    When I follow "Sign up"
    And I fill in the following within ".no-boxes":
      | e-Mail                | josesilva@example.com |
      | Username              | josesilva             |
      | Password              | secret                |
      | Password confirmation | secret                |
      | Full name             | José da Silva         |
    And wait for the captcha signup time
    And I press "Create my account"
    And I go to josesilva's confirmation URL
    And I fill in "Username" with "josesilva"
    And I fill in "Password" with "secret"
    And I press "Log in"
    Then I should be on /profile/josesilva

  @selenium
  Scenario: user should go to his control panel after following confirmation link
    Given the environment is configured to redirect to profile control panel after login
    And feature "skip_new_user_email_confirmation" is disabled on environment
    And I am on /search/people
    When I follow "Sign up"
    And I fill in the following within ".no-boxes":
      | e-Mail                | josesilva@example.com |
      | Username              | josesilva             |
      | Password              | secret                |
      | Password confirmation | secret                |
      | Full name             | José da Silva         |
    And wait for the captcha signup time
    And I press "Create my account"
    And I go to josesilva's confirmation URL
    And I fill in "Username" with "josesilva"
    And I fill in "Password" with "secret"
    And I press "Log in"
    Then I should be on /myprofile/josesilva

  @selenium
  Scenario: user should go to his profile page after following confirmation link
    Given the environment is configured to redirect to user profile page after login
    And feature "skip_new_user_email_confirmation" is disabled on environment
    And I am on /search/people
    When I follow "Sign up"
    And I fill in the following within ".no-boxes":
      | e-Mail                | josesilva@example.com |
      | Username              | josesilva             |
      | Password              | secret                |
      | Password confirmation | secret                |
      | Full name             | José da Silva         |
    And wait for the captcha signup time
    And I press "Create my account"
    And I go to josesilva's confirmation URL
    And I fill in "Username" with "josesilva"
    And I fill in "Password" with "secret"
    And I press "Log in"
    Then I should be on /profile/josesilva

  @selenium
  Scenario: user should go to the environment homepage after following confirmation link
    Given the environment is configured to redirect to site homepage after login
    And feature "skip_new_user_email_confirmation" is disabled on environment
    And I am on /search/people
    When I follow "Sign up"
    And I fill in the following within ".no-boxes":
      | e-Mail                | josesilva@example.com |
      | Username              | josesilva             |
      | Password              | secret                |
      | Password confirmation | secret                |
      | Full name             | José da Silva         |
    And wait for the captcha signup time
    And I press "Create my account"
    And I go to josesilva's confirmation URL
    And I fill in "Username" with "josesilva"
    And I fill in "Password" with "secret"
    And I press "Log in"
    Then I should be on the homepage

  @selenium
  Scenario: join community on signup
    Given the following users
      | login | name |
      | mariasilva | Maria Silva |
    And the following communities
       | name           | identifier    | owner     |
       | Free Software  | freesoftware  | mariasilva |
    And feature "skip_new_user_email_confirmation" is disabled on environment
    And I am on /freesoftware
    When I follow "Join"
    And I follow "New user"
    And I fill in the following within ".no-boxes":
      | e-Mail                | josesilva@example.com |
      | Username              | josesilva             |
      | Password              | secret                |
      | Password confirmation | secret                |
      | Full name             | José da Silva         |
    And wait for the captcha signup time
    And I press "Create my account"
    And I go to josesilva's confirmation URL
    And I fill in "Username" with "josesilva"
    And I fill in "Password" with "secret"
    And I press "Log in"
    Then "José da Silva" should be a member of "Free Software"

  @selenium
  Scenario: user registration is moderated by admin
    Given feature "admin_must_approve_new_users" is enabled on environment
    And feature "skip_new_user_email_confirmation" is disabled on environment
    And I go to /account/signup
    And I fill in "Username" with "teste"
    And I fill in "Password" with "123456"
    And I fill in "Password confirmation" with "123456"
    And I fill in "e-Mail" with "teste@teste.com"
    And I fill in "Full name" with "Teste da Silva"
    And wait for the captcha signup time
    And I press "Create my account"
    And I go to teste's confirmation URL
    And I am logged in as admin
    And I follow "Control panel"
    And I follow "Tasks"
    And I choose "Accept"
    And I press "Apply!"
    And I follow "Logout"
    And Teste da Silva's account is activated
    And I follow "Login"
    And I fill in "Username / Email" with "teste"
    And I fill in "Password" with "123456"
    And I press "Log in"
    Then I should see "teste"


  @selenium
  Scenario: user registration is not accepted by the admin
    Given feature "admin_must_approve_new_users" is enabled on environment
    And feature "skip_new_user_email_confirmation" is disabled on environment
    And I go to /account/signup
    And I fill in "Username" with "teste"
    And I fill in "Password" with "123456"
    And I fill in "Password confirmation" with "123456"
    And I fill in "e-Mail" with "teste@teste.com"
    And I fill in "Full name" with "Teste da Silva"
    And wait for the captcha signup time
    And I press "Create my account"
    And I go to teste's confirmation URL
    And I am logged in as admin
    And I follow "Control panel"
    And I follow "Tasks"
    And I choose "Reject"
    And I press "Apply!"
    And I follow "Logout"
    And I follow "Login"
    And I fill in "Username / Email" with "teste"
    And I fill in "Password" with "123456"
    And I press "Log in"
    Then I should not see "teste"
