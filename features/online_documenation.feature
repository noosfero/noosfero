Feature: online documentation
  As a user
  I want to read the documentation
  So that I know how to do something in Noosfero

  Scenario: initial page of online documentation
    When I go to /doc
    Then I should see "Noosfero online documentation"

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
    

