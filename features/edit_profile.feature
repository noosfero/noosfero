Feature: edit profile

  Background:
    Given the following users
      | login   |
      | joao    |
    Given I am logged in as "joao"

  Scenario: Warn about invalid birth date when active
    Given the following person fields are active fields
      | display_name |
      | birth_date |
    When I go to joao's control panel
    And I follow "Profile Info and settings"
    And I select "November"
    And I select "15"
    And I press "Save"
    Then I should see "Birth date is invalid"
    And I should not see "Birth date is mandatory"

  Scenario: Warn about invalid birth date when required
    Given the following person fields are required fields
      | display_name |
      | birth_date |
    When I go to joao's control panel
    And I follow "Profile Info and settings"
    And I select "November"
    And I select "15"
    And I press "Save"
    Then I should see "Birth date is invalid"
    And I should see "Birth date is mandatory"

  Scenario: Not warn if birth date is valid when active
    Given the following person fields are active fields
      | display_name |
      | birth_date |
    When I go to joao's control panel
    And I follow "Profile Info and settings"
    And I select "November"
    And I select "15"
    And I select "1980"
    And I press "Save"
    Then I should not see "Birth date is invalid"
    And I should not see "Birth date is mandatory"

  Scenario: Not warn if birth date is valid when required
    Given the following person fields are required fields
      | display_name |
      | birth_date |
    When I go to joao's control panel
    And I follow "Profile Info and settings"
    And I select "November"
    And I select "15"
    And I select "1980"
    And I press "Save"
    Then I should not see "Birth date is invalid"
    And I should not see "Birth date is mandatory"

  @selenium
  Scenario: Alert about url change
    Given the following community
      | identifier | name | owner |
      | o-rappa | O Rappa | joao  |
    And feature "enable_organization_url_change" is enabled on environment
    When I go to O Rappa's control panel
    And I follow "Community Info and settings" and wait
    Then I should not see "WARNING! You are about to change the address"
    When I fill in "Address" with "banda-o-rappa"
    Then I should see "WARNING! You are about to change the address"

  @selenium
  Scenario: Confirm url change
    Given the following community
      | identifier | name | owner |
      | o-rappa | O Rappa | joao  |
    And feature "enable_organization_url_change" is enabled on environment
    When I go to O Rappa's control panel
    And I follow "Community Info and settings" and wait
    When I fill in "Address" with "banda-o-rappa"
    Then I should see "WARNING! You are about to change the address"
    When I follow "Yes"
    Then I should not see "WARNING! You are about to change the address"

  @selenium
  Scenario: Cancel url change
    Given the following community
      | identifier | name | owner |
      | o-rappa | O Rappa | joao  |
    And feature "enable_organization_url_change" is enabled on environment
    When I go to O Rappa's control panel
    And I follow "Community Info and settings" and wait
    When I fill in "Address" with "banda-o-rappa"
    Then I should see "WARNING! You are about to change the address"
    When I follow "No"
    Then I should not see "WARNING! You are about to change the address"
