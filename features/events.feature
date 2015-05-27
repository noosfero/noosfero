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
      | josesilva | Some Conference    | 2009-10-22 |

  Scenario: go to next month
    Given I am on /profile/josesilva/events/2009/10
    When I follow "November"
    Then I should see "November 2009" within ".current-month"

  Scenario: go to next month in global agenda
    Given I am on /search/events?year=2009&month=11
    When I follow "December"
    Then I should see "December 2009" within ".current-month"

  Scenario: go to previous month
    Given I am on /profile/josesilva/events/2009/10
    When I follow "September"
    Then I should see "September 2009" within ".current-month"

  Scenario: go to previous month in global agenda
    Given I am on /search/events?year=2009&month=11
    When I follow "October"
    Then I should see "October 2009" within ".current-month"

  Scenario: go to next month by clicking in month name
    Given I am on /profile/josesilva/events/2009/10
    When I follow "November"
    Then I should see "November 2009" within ".current-month"

  Scenario: go to previous month by clicking in month name
    Given I am on /profile/josesilva/events/2009/10
    When I follow "September"
    Then I should see "September 2009" within ".current-month"

  Scenario: go to specific day in global agenda
    Given I am on the homepage
    When I am on /search/events?year=2009&month=11&day=12
    Then I should see "Events for November, 2009"

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
    Then I should see "WikiSym 2009"

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
    When I am on /search/events?year=2009&month=10&day=24
    Then I should see "Another Conference"
    And I should see "Manuel Birthday"

  @selenium
  Scenario: provide links to days with events
    Given I am on /profile/josesilva/events/2009/10
    Then I should see "24" link
    When I follow "November"
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
    And I should see "Another Conference" within "#agenda"
    And I should see "Some Conference" within "#agenda"
    When I follow "24"
    Then I should see "Another Conference" within "#agenda"
    And I should not see "Some Conference" within "#agenda"

  @selenium
  Scenario: show events in a range when i follow a specific day
    Given the following events
      | owner     | name              | start_date | end_date   |
      | josesilva | YAPC::Brasil 2010 | 2010-10-30 | 2010-11-01 |
    And I am on /profile/josesilva/events/2010/10
    And I should see "YAPC::Brasil 2010"
    When I follow "31"
    Then I should see "YAPC::Brasil 2010"

  Scenario: provide button to go back to profile homepage
    Given the following articles
      | owner     | name        | homepage |
      | josesilva | my homepage | true     |
    Given I am on /profile/josesilva/events
    When I follow "Back to josesilva"
    Then I should be on josesilva's homepage

  Scenario: provide button to create new event
    Given I am logged in as "josesilva"
    When I am on /profile/josesilva/events/2020/12/1
    Then I should see "New event" link

  Scenario: not provide button to create new event if I am not logged
    When I am on /profile/josesilva/events/2020/12/1
    Then I should not see "New event" link

  Scenario: not provide button to create new event if I haven't permission
    Given the following users
      | login    |
      | fudencio |
    Given I am logged in as "josesilva"
    When I am on /profile/fudencio/events/2020/12/1
    Then I should not see "New events" link

  Scenario: display environment name in global agenda
    When I am on /search/events
    Then I should see "Colivre.net's Events"


  @selenium
  Scenario: published events should be listed in the agenda too
    Given the following community
      | identifier | name |
      | sample-community | Sample Community |
    And I am logged in as "josesilva"
    And "josesilva" is a member of "Sample Community"
    And I go to josesilva's control panel
    And I follow "Manage Content"
    And I follow "Another Conference"
    And I follow "Spread this"
    And I type in "Sample Community" into autocomplete list "search-communities-to-publish" and I choose "Sample Community"
    And I press "Spread this"
    And I am on /profile/sample-community/events/2009/10/24
    Then I should see "Another Conference"

  Scenario: events that are not allowed to the user should not be displayed nor listed in the calendar
    Given the following events
      | owner     | name               | start_date | published |
      | josesilva | Unpublished event  | 2009-10-25 | false     |
    When I am on /profile/josesilva/events/2009/10/25
    Then I should not see "Unpublished event"
    And I should not see "25" link

  Scenario: events that are allowed to the user should be displayed and listed in the calendar
    Given the following events
      | owner     | name               | start_date | published |
      | josesilva | Unpublished event  | 2009-10-25 | false     |
    And I am logged in as "josesilva"
    When I am on /profile/josesilva/events/2009/10/25
    Then I should see "Unpublished event"
    And I should see "25" link

  Scenario: events have lead field
    Given I am logged in as "josesilva"
    And I am on josesilva's Event creation
    Then I should see "Lead"

  @selenium-fixme
  Scenario: events lead should be shown on blogs with short format
    Given I am logged in as "josesilva"
    And I am on josesilva's control panel
    And I follow "Configure blog"
    And I select "First paragraph" from "How to display posts:"
    And I press "Save"
    And I follow "New post"
    And I follow "A calendar event"
    And I fill in "Title" with "Leaded event"
    And I type "This is the abstract." in TinyMCE field "article_abstract"
    And I type "This is the real text." in TinyMCE field "article_body"
    And I press "Save"
    When I am on josesilva's blog
    Then I should see "Leaded event"
    And I should see "This is the abstract."
    And I should not see "This is the real text."

  Scenario: show range date of event
    Given I am on /profile/josesilva/events/2009/10
    And the following events
      | owner     | name         | start_date | end_date   |
      | josesilva | WikiSym 2009 | 2009-10-25 | 2009-10-27 |
    When I am on /profile/josesilva/events/2009/10/26
    Then I should see "October 25, 2009 to October 27, 2009"

  Scenario: show place of the event
    Given I am on /profile/josesilva/events/2009/10
    And the following events
      | owner     | name         | start_date | end_date   |  address      |
      | josesilva | WikiSym 2009 | 2009-10-25 | 2009-10-27 |  Earth Planet |
    When I am on /profile/josesilva/events/2009/10/26
    Then I should see "Place: Earth Planet"

  Scenario: show event name as link
    Given the following events
      | owner     | name               | start_date |
      | josesilva | Unpublished event  | 2009-10-25 |
    And I am logged in as "josesilva"
    When I am on /profile/josesilva/events/2009/10/25
    Then I should see "Unpublished event" link

  Scenario: go to event page
    Given the following events
      | owner     | name               | start_date |
      | josesilva | Oktoberfest  | 2009-10-25 |
    Given I am on /profile/josesilva/events/2009/10
    When I follow "Oktoberfest"
    Then I should see "Oktoberfest"

  Scenario: list events paginated for a specific profile for the month
    Given I am logged in as admin
    And the following users
      | login      |
      | josemanuel |
    And I am logged in as "josemanuel"
    And the following events
      | owner      | name              | start_date |
      | josemanuel | Event 5           | 2009-10-12 |
      | josemanuel | Event 3           | 2009-10-15 |
      | josemanuel | Test Event        | 2009-10-15 |
      | josemanuel | Oktoberfest       | 2009-10-19 |
      | josemanuel | WikiSym           | 2009-10-21 |
      | josemanuel | Free Software     | 2009-10-22 |
      | josemanuel | Rachel Birthday   | 2009-10-23 |
      | josemanuel | Manuel Birthday   | 2009-10-24 |
      | josemanuel | Michelle Birthday | 2009-10-25 |
      | josemanuel | Lecture Allien 10 | 2009-10-26 |
      | josemanuel | Lecture Allien 11 | 2009-10-26 |
      | josemanuel | Lecture Allien 12 | 2009-10-26 |
      | josemanuel | Lecture Allien 13 | 2009-10-26 |
      | josemanuel | Lecture Allien 14 | 2009-10-26 |
      | josemanuel | Lecture Allien 15 | 2009-10-26 |
      | josemanuel | Lecture Allien 16 | 2009-10-26 |
      | josemanuel | Lecture Allien 17 | 2009-10-26 |
      | josemanuel | Lecture Allien 18 | 2009-10-26 |
      | josemanuel | Lecture Allien 19 | 2009-10-26 |
      | josemanuel | Lecture Allien 20 | 2009-10-26 |
      | josemanuel | Party On          | 2009-10-27 |

    When I am on /profile/josemanuel/events/2009/10
    Then I should not see "Party On" within "#agenda-items"
    When I follow "Next"
    Then I should see "Party On" within "#agenda-items"
