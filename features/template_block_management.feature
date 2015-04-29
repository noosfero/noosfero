Feature: user template
  As an user
  I want to create templates with mirror blocks
  In order to keep these blocks always updated

  Background:
    Given the following users
      | login  | name       | is_template |
      | person | person     | true        |
    And the following blocks
      | owner  | type          | mirror |
      | person | ArticleBlock  | true   |
      | person | RawHTMLBlock  | false  |
    And I go to /account/signup
    And I fill in "Username" with "mario"
    And I fill in "Password" with "123456"
    And I fill in "Password confirmation" with "123456"
    And I fill in "e-Mail" with "mario@mario.com"
    And I fill in "Full name" with "Mario"
    And wait for the captcha signup time
    And I press "Create my account"
    And I am logged in as admin

  @selenium
  Scenario: The block Article name is changed
    Given I am on person's control panel
    And I follow "Edit sideboxes"
    And display ".button-bar"
    And I follow "Edit" within ".article-block"
    And I fill in "Custom title for this block:" with "Mirror"
    And I press "Save"
    And I go to /profile/mario
    Then I should see "Mirror"

  @selenium
  Scenario: The block LinkList is changed but the user's block doesnt change
    Given I am on person's control panel
    And I follow "Edit sideboxes"
    And display ".button-bar"
    And I follow "Edit" within ".raw-html-block"
    And I fill in "Custom title for this block:" with "Raw HTML Block"
    And I press "Save"
    And I go to /profile/mario
    Then I should not see "Raw HTML Block"

  @selenium
  Scenario: The block Article cannot move or modify
    Given I am on person's control panel
    And I follow "Edit sideboxes"
    And display ".button-bar"
    And I follow "Edit" within ".article-block"
    And I select "Cannot be moved" from "Move options:"
    And I select "Cannot be modified" from "Edit options:"
    And I press "Save"
    And I follow "Logout"
    And Mario's account is activated
    And I follow "Login"
    And I fill in "Username / Email" with "mario"
    And I fill in "Password" with "123456"
    And I press "Log in"
    And I go to /myprofile/mario
    And I follow "Edit sideboxes"
    And display ".button-bar"
    Then I should not see "Edit" within ".article-block"
