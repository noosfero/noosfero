Feature: online documentation
  As a user
  I want to read the documentation
  So that I know how to do something in Noosfero

  Scenario: initial page of online documentation
    When I go to /doc
    Then I should see "Noosfero online documentation"

  Scenario: displaying index content
    When I go to /doc
    Then I should see "Administration"
    And I should see "User features"

