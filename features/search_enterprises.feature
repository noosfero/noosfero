Feature: search enterprises
  As a noosfero user
  I want to search enterprises
  In order to find ones that interest me

  Scenario: show recent enterprises on index
    Given the following enterprises
      | identifier | name        | img    |
      | shop1      | Shoes shop  | shoes  |
      | shop2      | Fruits shop | fruits |
    And there are no pending jobs
    When I go to the search enterprises page
    Then I should see "Shoes shop" within "#search-results"
    And I should see Shoes shop's profile image
    And I should see "Fruits shop" within "#search-results"
    And I should see Fruits shop's profile image

  Scenario: show empty search results
    Given the following enterprises
      | identifier | name        |
      | shop1      | Shoes shop  |
      | shop2      | Fruits shop |
    When I search enterprises for "something unrelated"
    Then I should see "None" within ".search-results-type-empty"

  Scenario: simple search for enterprise
    Given the following enterprises
      | identifier | name        | img    |
      | shop1      | Shoes shop  | shoes  |
      | shop2      | Fruits shop | fruits |
    When I go to the search enterprises page
    And I fill in "search-input" with "shoes"
    And I press "Search"
    Then I should see "Shoes shop" within ".only-one-result-box"
    And I should see Shoes shop's profile image
    And I should not see "Fruits shop"
    And I should not see Fruits shop's profile image

  Scenario: link to enterprise homepage on search results
    Given the following enterprises
      | identifier | name        |
      | shop1      | Shoes shop  |
    And the following articles
      | owner | name | body | homepage |
      | shop1 | Shoes home | This is the <i>homepage</i> of Shoes shop! It has a very long and pretty vague description, just so we can test wether the system will correctly create an excerpt of this text. We should probably talk about shoes. | true |
    And I search enterprises for "shoes"
    When I follow "Shoes shop"
    Then I should be on shop1's homepage

  @selenium
  Scenario: show clean enterprise homepage on search results
    Given the following enterprises
      | identifier | name        |
      | shop1      | Shoes shop  |
    And the following articles
      | owner | name | body | homepage |
      | shop1 | Shoes home | This is the <i>homepage</i> of Shoes shop! It has a very long and pretty vague description, just so we can test wether the system will correctly create an excerpt of this text. We should probably talk about shoes. | true |
    When I search enterprises for "shoes"
    And I select "Full" from "display"
    Then I should see "This is the homepage of" within ".search-enterprise-description"
    And I should see "about sho..." within ".search-enterprise-description"

  @selenium
  Scenario: show clean enterprise description on search results
    Given the following enterprises
      | identifier | name | description |
      | shop4 | Clothes shop | This <b>clothes</b> shop also sells shoes! This too has a very long and pretty vague description, just so we can test wether the system will correctly create an excerpt of this text. Clothes are a really important part of our lives. |
    When I search enterprises for "clothes"
    And I select "Full" from "display"
    And I should see "This clothes shop" within ".search-enterprise-description"
    And I should see "really import..." within ".search-enterprise-description"

  Scenario: find enterprises without exact query
    Given the following enterprises
      | identifier | name                            |
      | noosfero   | Noosfero Developers Association |
    When I go to the search enterprises page
    And I fill in "search-input" with "Noosfero Developers"
    And I press "Search"
    Then I should see "Noosfero Developers Association" within "#search-results"
