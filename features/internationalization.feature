Feature: internationalization
  As a non-English speaking user
  I want to select my own language
  In order to be able to use the system

  Scenario: default language
    When I go to the homepage
    Then the site should be in English

  @default_locale_config
  Scenario: different default locale configured locally
    Given Noosfero is configured to use Portuguese as default
    When I go to the homepage
    Then the site should be in Portuguese

  Scenario: detecting language from browser
    Given my browser prefers Portuguese
    When I go to the homepage
    Then the site should be in Portuguese
    When my browser prefers French
    And I go to the homepage
    Then the site should be in French

  Scenario: explictly selecting a language
    Given I am on the homepage
    When I follow "Français"
    Then the site should be in French
    When I follow "Português"
    Then the site should be in Portuguese

  Scenario: language set by previous users
    Given a user accessed in English before
    And my browser prefers Portuguese
    When I go to the homepage
    Then the site should be in Portuguese

  Scenario: using the generic form of a language
    Given my browser prefers Brazilian Portuguese
    When I go to the homepage
    Then the site should be in Portuguese

  Scenario: unsupported locale
    # this test assumes that Klingon is unsupported. If it becomes supported,
    # then we should change this test to use another unsupported language.
    Given my browser prefers Klingon
    When I go to the homepage
    Then the site should be in English
