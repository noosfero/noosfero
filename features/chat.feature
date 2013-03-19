Feature: chat
  As a Noosfero user
  I want to chat with my friends

  Background:
    Given the following users
      | login | name |
      | tame | Tame |
      | mariasilva | Maria Silva |
      | josesilva  | Jose Silva  |
    And "tame" is online in chat
    And "mariasilva" is online in chat
    And "josesilva" is online in chat
    And "tame" is friend of "mariasilva"
    And "tame" is friend of "josesilva"

  Scenario: provide link to open chat
    Given feature "xmpp_chat" is enabled on environment
    And I am logged in as "tame"
    Then I should see "Open chat" within "#user"

  @selenium
  Scenario: provide the chat online users content
    Given feature "xmpp_chat" is enabled on environment
    And I am logged in as "tame"
    Then I should see "Friends in chat "

  @selenium
  Scenario: provide the chat online users list
    Given the profile "tame" has no blocks
    And feature "xmpp_chat" is enabled on environment
    And I am logged in as "tame"
    And I go to tame's profile
    When I follow "chat-online-users-title"
    Then I should see "Maria Silva"
    And I should see "Jose Silva"

  Scenario: not provide link to chat when environment not support that
    Given I am logged in as "tame"
    Then I should not see "Open chat" within "#user"

  Scenario: not provide link to chat when the user is logged out
    Given I am on tame's homepage
    Then I should not see "Open chat" within "#user"

  @selenium
  Scenario: not provide the chat online users list when environment not support that
    Given I am logged in as "tame"
    Then I should not see "Friends in chat "

  Scenario: block access to chat when environment not support that
    Given I am logged in as "tame"
    When I go to chat
    Then I should see "There is no such page"

  Scenario: block access to chat for guest users
    Given feature "xmpp_chat" is enabled on environment
    When I go to chat
    Then I should be on login page

  @selenium
  Scenario: open chat in a new window
    Given feature "xmpp_chat" is enabled on environment
    And I am logged in as "tame"
    When I follow "Open chat"
    And I select window "noosfero_chat"
    Then I should see "Chat - Colivre.net - Friends online (0)"

  @selenium
  Scenario: open chat with an online user in a new window
    Given the profile "tame" has no blocks
    And feature "xmpp_chat" is enabled on environment
    And I am logged in as "tame"
    And I go to tame's profile
    When I follow "chat-online-users-title"
    And I follow "Maria Silva"
    And I select window "noosfero_chat"
    Then I should see "Chat - Colivre.net - Friends online (0)"

  @selenium
  Scenario: chat starts disconnected by default
    Given feature "xmpp_chat" is enabled on environment
    And I am logged in as "tame"
    When I follow "Open chat"
    And I select window "noosfero_chat"
    Then I should see "Offline" within "a"

  @selenium
  Scenario: view options to change my chat status through menu
    Given feature "xmpp_chat" is enabled on environment
    And I am logged in as "tame"
    And I follow "Open chat"
    When I select window "noosfero_chat"
    Then "Online" should not be visible within "#user-status"
    And "Busy" should not be visible within "#user-status"
    And "Sign out of chat" should not be visible within "#user-status"
    When I follow "Offline"
    Then "Online" should be visible within "#user-status"
    And "Busy" should be visible within "#user-status"
    And "Sign out of chat" should be visible within "#user-status"

  @selenium
  Scenario: link to open chatroom of a community
    Given the following communities
      | identifier | name |
      | autoramas | Autoramas |
    And "Tame" is a member of "Autoramas"
    And feature "xmpp_chat" is enabled on environment
    And I am logged in as "tame"
    When I go to autoramas's profile
    Then I should see "Enter chat room"

  @selenium
  Scenario: not see link to open chatroom of a community if not a member
    Given the following communities
      | identifier | name |
      | autoramas | Autoramas |
    And feature "xmpp_chat" is enabled on environment
    And I am logged in as "tame"
    When I go to autoramas's profile
    Then I should not see "Enter chat room" within "a"

  @selenium
  Scenario: not see link to open chatroom of a community if xmpp_chat disabled
    Given the following communities
      | identifier | name |
      | autoramas | Autoramas |
    And "Tame" is a member of "Autoramas"
    And I am logged in as "tame"
    When I go to autoramas's profile
    Then I should not see "Enter chat room" within "a"

  @selenium
  Scenario: open chatroom of a community in a new window
    Given feature "xmpp_chat" is enabled on environment
    And the following communities
      | identifier | name |
      | autoramas | Autoramas |
    And "Tame" is a member of "Autoramas"
    And I am logged in as "tame"
    When I go to autoramas's profile
    And I follow "Enter chat room"
    And I select window "noosfero_chat"
    Then I should see "Chat - Colivre.net - Friends online (0)"
