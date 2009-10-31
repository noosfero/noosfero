Feature: events
  As a noosfero visitor
  I want to see some events

  Background:
    Given the following users
      | login      |
      | josesilva  |
    And the following events
      | owner     | name               | start_date |
      | josesilva | Another Conference | 2009-10-24 |

  Scenario: go to next month
    Given I am on /profile/josesilva/events/2009/10
    When I follow "next →"
    Then I should see "November 2009" within ".current-month"

  Scenario: go to next month in global agenda
    Given I am on /assets/events?year=2009&month=11
    When I follow "next →"
    Then I should see "December 2009" within ".current-month"

  Scenario: go to previous month
    Given I am on /profile/josesilva/events/2009/10
    When I follow "← previous"
    Then I should see "September 2009" within ".current-month"

  Scenario: go to previous month in global agenda
    Given I am on /assets/events?year=2009&month=11
    When I follow "← previous"
    Then I should see "October 2009" within ".current-month"

  Scenario: go to next month by clicking in month name
    Given I am on /profile/josesilva/events/2009/10
    When I follow "November 2009"
    Then I should see "November 2009" within ".current-month"

  Scenario: go to previous month by clicking in month name
    Given I am on /profile/josesilva/events/2009/10
    When I follow "September 2009"
    Then I should see "September 2009" within ".current-month"

  Scenario: go to specific day
    Given I am on the homepage
    When I am on /profile/josesilva/events/2009/01/20
    Then I should see "Events for January 20, 2009"

  Scenario: go to specific day in global agenda
    Given I am on the homepage
    When I am on /assets/events?year=2009&month=11&day=12
    Then I should see "Events for November 12, 2009"

  Scenario: list events for specific day
    Given I am on /profile/josesilva/events/2009/10
    And the following events
      | owner     | name         | start_date |
      | josesilva | WikiSym 2009 | 2009-10-25 |
    When I am on /profile/josesilva/events/2009/10/25
    Then I should see "WikiSym 2009"

  Scenario: dont list events for non-selected day
    Given I am on /profile/josesilva/events/2009/10
    And the following events
      | owner     | name         | start_date |
      | josesilva | WikiSym 2009 | 2009-10-25 |
    When I am on /profile/josesilva/events/2009/10/20
    Then I should not see "WikiSym 2009"

  Scenario: list event between a range
    Given I am on /profile/josesilva/events/2009/10
    And the following events
      | owner     | name         | start_date | end_date   |
      | josesilva | WikiSym 2009 | 2009-10-25 | 2009-10-27 |
    When I am on /profile/josesilva/events/2009/10/26
    Then I should see "WikiSym 2009"

  Scenario: dont list events from other profiles
    Given the following users
      | login      |
      | josemanuel |
    And the following events
      | owner      | name            | start_date |
      | josemanuel | Manuel Birthday | 2009-10-24 |
    When I am on /profile/josesilva/events/2009/10/24
    Then I should see "Another Conference"
    And I should not see "Manuel Birthday"

  Scenario: list all events in global agenda
    Given the following users
      | login      |
      | josemanuel |
    And the following events
      | owner      | name            | start_date |
      | josemanuel | Manuel Birthday | 2009-10-24 |
    When I am on /assets/events?year=2009&month=10&day=24
    Then I should see "Another Conference"
    And I should see "Manuel Birthday"

  Scenario: ask for a day when no inform complete date
    When I am on /profile/josesilva/events/2009/5
    Then I should see "Select a day on the left to display it's events here"

  Scenario: ask for a day when no inform complete date in global agenda
    When I am on /assets/events?year=2009&month=5
    Then I should see "Select a day on the left to display it's events here"

  Scenario: provide links to days with events
    Given I am on /profile/josesilva/events/2009/10
    Then I should see "24" link
    When I follow "next →"
    Then I should see "24" link
    When I follow "next →"
    Then I should not see "24" link

  Scenario: provide links to all days between start and end date
    Given the following users
      | login    |
      | fudencio |
    And the following events
      | owner    | name              | start_date | end_date   |
      | fudencio | YAPC::Brasil 2009 | 2010-10-30 | 2010-11-01 |
    And I am on /profile/fudencio/events/2010/10
    Then I should not see "29" link
    And I should see "30" link
    And I should see "31" link
    And I should see "1" link

  @selenium
  Scenario: show events when i follow a specific day
    Given I am on /profile/josesilva/events/2009/10
    And I should not see "Another Conference"
    When I follow "24"
    Then I should see "Another Conference"

  @selenium
  Scenario: show events in a range when i follow a specific day
    Given the following events
      | owner     | name              | start_date | end_date   |
      | josesilva | YAPC::Brasil 2010 | 2010-10-30 | 2010-11-01 |
    And I am on /profile/josesilva/events/2010/10
    And I should not see "YAPC::Brasil 2010"
    When I follow "31"
    Then I should see "YAPC::Brasil 2010"

  Scenario: provide button to back from profile
    When I am on /profile/josesilva/events
    Then I should see "Back to josesilva" link

  Scenario: warn when there is no events
    When I am on /profile/josesilva/events/2020/12/1
    Then I should see "No events for this date"
