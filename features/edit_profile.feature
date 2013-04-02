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
    And I follow "Edit Profile"
    And I select "November" from "profile_data_birth_date_2i"
    And I select "15" from "profile_data_birth_date_3i"
    And I press "Save"
    Then I should see "Birth date is invalid"
    And I should not see "Birth date can't be blank"

  Scenario: Warn about invalid birth date when required
    Given the following person fields are required fields
      | display_name |
      | birth_date |
    When I go to joao's control panel
    And I follow "Edit Profile"
    And I select "November" from "profile_data_birth_date_2i"
    And I select "15" from "profile_data_birth_date_3i"
    And I press "Save"
    Then I should see "Birth date is invalid"
    And I should not see "Birth date can't be blank"

  Scenario: Not warn if birth date is valid when active
    Given the following person fields are active fields
      | display_name |
      | birth_date |
    When I go to joao's control panel
    And I follow "Edit Profile"
    And I select "November" from "profile_data_birth_date_2i"
    And I select "15" from "profile_data_birth_date_3i"
    And I select "1980" from "profile_data_birth_date_1i"
    And I press "Save"
    Then I should not see "Birth date is invalid"
    And I should not see "Birth date is mandatory"

  Scenario: Not warn if birth date is valid when required
    Given the following person fields are required fields
      | display_name |
      | birth_date |
    When I go to joao's control panel
    And I follow "Edit Profile"
    And I select "November" from "profile_data_birth_date_2i"
    And I select "15" from "profile_data_birth_date_3i"
    And I select "1980" from "profile_data_birth_date_1i"
    And I press "Save"
    Then I should not see "Birth date is invalid"
    And I should not see "Birth date is mandatory"

  @selenium
  Scenario: Alert about url change
    Given the following community
      | identifier | name | owner |
      | o-rappa | O Rappa | joao  |
    And feature "enable_organization_url_change" is enabled on environment
    When I go to o-rappa's control panel
    And I follow "Community Info and settings"
    And I should not see "identifier-change-confirmation"
    When I fill in "Address" with "banda-o-rappa"
    And I should see "identifier-change-confirmation"

  @selenium
  Scenario: Confirm url change
    Given the following community
      | identifier | name | owner |
      | o-rappa | O Rappa | joao  |
    And feature "enable_organization_url_change" is enabled on environment
    When I go to o-rappa's control panel
    And I follow "Community Info and settings"
    When I fill in "Address" with "banda-o-rappa"
    Then I should see "identifier-change-confirmation"
    When I follow "Yes"
    Then "identifier-change-confirmation" should not be visible within "profile-identifier-formitem"

  @selenium
  Scenario: Cancel url change
    Given the following community
      | identifier | name | owner |
      | o-rappa | O Rappa | joao  |
    And feature "enable_organization_url_change" is enabled on environment
    When I go to o-rappa's control panel
    And I follow "Community Info and settings"
    When I fill in "Address" with "banda-o-rappa"
    Then I should see "identifier-change-confirmation"
    When I follow "No"
    Then "identifier-change-confirmation" should not be visible within "profile-identifier-formitem"
