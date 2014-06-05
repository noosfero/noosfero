@docs
Feature: online manual
  As a user
  I want to read the manual
  So that I know how to do something in Noosfero

  Background:
    Given the documentation is built

  Scenario: initial page of online manual
    When I go to /doc
    Then I should see "Noosfero online manual"

  Scenario: displaying index content
    When I go to /doc
    Then I should see "User features"
    And I should see "Content Management"

  Scenario: displaying section
    When I go to /doc
    And I follow "User features"
    Then I should see "Accepting friends"
    And I should see "Commenting"

  Scenario: displaying topic
    When I go to /doc
    And I follow "User features"
    And I follow "Commenting"
    Then I should see "How to access"

  Scenario: adding title on browser
    When I go to /doc
    Then the page title should be "Online Manual - Colivre.net"

  Scenario: adding title on browser in a section
    When I go to /doc
    And I follow "User features"
    Then the page title should be "User features - Online Manual - Colivre.net"

  Scenario: adding title on browser in a topic
    When I go to /doc
    And I follow "User features"
    And I follow "Commenting articles"
    Then the page title should be "Commenting articles - User features - Online Manual - Colivre.net"
