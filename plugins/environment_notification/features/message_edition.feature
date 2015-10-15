Feature: Create envronment notification message
  As an admin user
  I want to create an environment notification
  In order to notificate users

  @selenium
  Scenario: mce restricted mode should show on message creation
    Given I am logged in as admin
    And I follow "Administration"
    And I follow "Plugins"
    And I follow "Configuration"
    And I follow "New Notification"
    Then The tinymce "toolbar1" should be "bold italic underline | link"
    Then The tinymce "menubar" should be "false"
