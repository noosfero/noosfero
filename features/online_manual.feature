Feature: online manual
  As a user
  I want to read the manual
  So that I know how to do something in Noosfero

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
    Then I should see "Online Manual - Colivre.net"

  Scenario: adding title on browser in a section
    When I go to /doc
    And I follow "User features"
    Then I should see "User features - Online Manual - Colivre.net"

  Scenario: adding title on browser in a topic
    When I go to /doc
    And I follow "User features"
    And I follow "Commenting articles"
    Then I should see "Commenting articles - User features - Online Manual - Colivre.net"
