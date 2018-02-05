Feature: events search
  As a noosfero visitor
  I want to search for environment events

  Background:
    Given the following users
      | login        |
      | josesilva  	 |
      | mariasantos  |
    And the following events
      | owner       | name                    | start_date  |
      | josesilva   | Another Conference      | 2018-10-24  |
      | mariasantos | Different Conference    | 2018-10-08  |

	@selenium
  Scenario: filter events by day when selecting in the calendar
    Given I am on /search/events?year=2018&month=10
		And I follow "8" within ".agenda-calendar"
    Then I should see "Different Conference"
    And should not see "Another Conference"

	@selenium
	Scenario: show events of the month again after clicking on the day
    Given I am on /search/events?year=2018&month=10
		And I follow "8" within ".agenda-calendar"
		And I follow "October" within ".agenda-calendar"
    Then I should see "Different Conference"
    And should see "Another Conference"

	Scenario: paginate events of the month correctly
    Given the following events
      | owner       | name              | start_date |
      | josesilva   | Event 5           | 2018-10-27 |
      | josesilva   | Event 3           | 2018-10-27 |
      | josesilva   | Test Event        | 2018-10-27 |
      | josesilva   | Oktoberfest       | 2018-10-27 |
      | josesilva   | WikiSym           | 2018-10-27 |
      | josesilva   | Free Software     | 2018-10-27 |
      | josesilva   | Rachel Birthday   | 2018-10-27 |
      | josesilva   | Manuel Birthday   | 2018-10-27 |
      | josesilva   | Michelle Birthday | 2018-10-27 |
      | mariasantos | Lecture Allien 10 | 2018-10-27 |
      | mariasantos | Lecture Allien 11 | 2018-10-27 |
      | mariasantos | Lecture Allien 12 | 2018-10-27 |
      | mariasantos | Lecture Allien 13 | 2018-10-27 |
      | mariasantos | Lecture Allien 14 | 2018-10-27 |
      | mariasantos | Lecture Allien 15 | 2018-10-27 |
      | mariasantos | Lecture Allien 16 | 2018-10-27 |
      | mariasantos | Lecture Allien 17 | 2018-10-27 |
      | mariasantos | Lecture Allien 18 | 2018-10-27 |
      | mariasantos | Lecture Allien 19 | 2018-10-27 |
      | mariasantos | Lecture Allien 20 | 2018-10-27 |
      | josesilva   | Party On          | 2018-10-28 |
    And I am on /search/events?year=2018&month=10
    When I follow "Next" within "#events-of-the-day"
    Then I should see "Party On"

	@selenium
	Scenario: paginate events of the day correctly
    Given the following events
      | owner       | name              | start_date |
      | josesilva   | Event 5           | 2018-10-15 |
      | josesilva   | Event 3           | 2018-10-15 |
      | josesilva   | Test Event        | 2018-10-15 |
      | josesilva   | Oktoberfest       | 2018-10-15 |
      | josesilva   | WikiSym           | 2018-10-15 |
      | josesilva   | Free Software     | 2018-10-15 |
      | josesilva   | Rachel Birthday   | 2018-10-15 |
      | josesilva   | Manuel Birthday   | 2018-10-15 |
      | josesilva   | Michelle Birthday | 2018-10-15 |
      | mariasantos | Lecture Allien 10 | 2018-10-15 |
      | mariasantos | Lecture Allien 11 | 2018-10-15 |
      | mariasantos | Lecture Allien 12 | 2018-10-15 |
      | mariasantos | Lecture Allien 13 | 2018-10-15 |
      | mariasantos | Lecture Allien 14 | 2018-10-15 |
      | mariasantos | Lecture Allien 15 | 2018-10-15 |
      | mariasantos | Lecture Allien 16 | 2018-10-15 |
      | mariasantos | Lecture Allien 17 | 2018-10-15 |
      | mariasantos | Lecture Allien 18 | 2018-10-15 |
      | mariasantos | Lecture Allien 19 | 2018-10-15 |
      | mariasantos | Lecture Allien 20 | 2018-10-15 |
      | josesilva   | Party On          | 2018-10-15 |
    And I am on /search/events?year=2018&month=10
		And follow "15" within ".agenda-calendar"
    And The page should contain only 20 "#agenda-items .event-date"
    When I follow "Next" within ".xhr-links"
    Then The page should contain only 1 "#agenda-items .event-date"
    And I should see "October 2018" within "#agenda"

	@selenium
	Scenario: paginate events of the month correctly after selecting a day
    Given the following events
      | owner       | name              | start_date |
      | josesilva   | Event 5           | 2018-10-27 |
      | josesilva   | Event 3           | 2018-10-27 |
      | josesilva   | Test Event        | 2018-10-27 |
      | josesilva   | Oktoberfest       | 2018-10-27 |
      | josesilva   | WikiSym           | 2018-10-27 |
      | josesilva   | Free Software     | 2018-10-27 |
      | josesilva   | Rachel Birthday   | 2018-10-27 |
      | josesilva   | Manuel Birthday   | 2018-10-27 |
      | josesilva   | Michelle Birthday | 2018-10-27 |
      | mariasantos | Lecture Allien 10 | 2018-10-27 |
      | mariasantos | Lecture Allien 11 | 2018-10-27 |
      | mariasantos | Lecture Allien 12 | 2018-10-27 |
      | mariasantos | Lecture Allien 13 | 2018-10-27 |
      | mariasantos | Lecture Allien 14 | 2018-10-27 |
      | mariasantos | Lecture Allien 15 | 2018-10-27 |
      | mariasantos | Lecture Allien 16 | 2018-10-27 |
      | mariasantos | Lecture Allien 17 | 2018-10-27 |
      | mariasantos | Lecture Allien 18 | 2018-10-27 |
      | mariasantos | Lecture Allien 19 | 2018-10-27 |
      | mariasantos | Lecture Allien 20 | 2018-10-27 |
      | josesilva   | Party On          | 2018-10-28 |
    And I am on /search/events?year=2018&month=10&day=17
		When I follow "October 2018"
    And follow "Next" within ".xhr-links"
    Then I should see "Party On"
    And I should see "October 2018" within "#agenda"

  Scenario: highlight the selected day when page is openened directly
    Given I am on /search/events?year=2018&month=10&day=8
    Then "8" should be visible within ".calendar-day.selected"

  @selenium
  Scenario: highlight the selected day when a day is selected
    Given I am on /search/events?year=2018&month=10
    And I follow "8"
    Then "8" should be visible within ".calendar-day.selected"
