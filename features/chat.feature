Feature: chat
  As a Noosfero user
  I want to chat with my friends

  Background:
    Given the following users
      | login | name |
      | tame | Tame |

  Scenario: provide link to open chat
    Given feature "xmpp_chat" is enabled on environment
    And I am logged in as "tame"
    Then I should see "Open chat" link

  Scenario: not provide link to chat when environment not support that
    Given I am logged in as "tame"
    Then I should not see "Open chat" link

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
  Scenario: chat starts disconnected by default
    Given feature "xmpp_chat" is enabled on environment
    And I am logged in as "tame"
    And I follow "Open chat"
    And I select window "noosfero_chat"
    Then I should see "Chat offline" link

  @selenium
  Scenario: view options to change my presence status through menu
    Given feature "xmpp_chat" is enabled on environment
    And I am logged in as "tame"
    And I follow "Open chat"
    And I select window "noosfero_chat"
    Then the "#chat-online" should not be visible
    Then the "#chat-busy" should not be visible
    Then the "#chat-disconnect" should not be visible
    Then I follow "Chat offline"
    Then the "#chat-connect" should be visible
    Then the "#chat-busy" should be visible
    Then the "#chat-disconnect" should be visible
