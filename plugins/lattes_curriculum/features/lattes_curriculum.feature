Feature: import lattes information
  As an user
  I want to inform my lattes url address
  So that I can import my academic informations automatically
  
  Background:
    Given "LattesCurriculumPlugin" plugin is enabled
    And I am logged in as admin
    And I go to /admin/plugins

  @selenium
  Scenario: Don't accept edit the profile with invalid lattes url
    And I check "Lattes Curriculum Plugin"
    And I follow "Save changes"
    And I go to /admin/features/manage_fields
    Given I follow "Person's fields"
    And I check "person_fields_lattes_url_active"
    And I check "person_fields_lattes_url_signup"
    And I follow "Save changes"
    Given I am on admin_user's control panel
    When I follow "Informations" within "#section-profile"
    And I fill in "Lattes URL" with "http://youtube.com.br/"
    And I follow "Save"
    Then I should see "Lattes url is invalid."

  @selenium
  Scenario: Import lattes informations
    And I check "Lattes Curriculum Plugin"
    And I follow "Save changes"
    And I go to /admin/features/manage_fields
    Given I follow "Person's fields"
    And I check "person_fields_lattes_url_active"
    And I check "person_fields_lattes_url_signup"
    And I follow "Save changes"
    Given I am on admin_user's control panel
    And the field lattes_url is public for all users
    When I follow "Informations" within "#section-profile"
    And I fill in "Lattes URL" with "http://lattes.cnpq.br/2864976228727880"
    And I follow "Save"
    And I go to /profile/admin_user#lattes_tab
    Then I should see "Lattes"

  @selenium
  Scenario: Don't show lattes informations for blank lattes urls
    And I check "Lattes Curriculum Plugin"
    And I follow "Save changes"
    And I go to /admin/features/manage_fields
    Given I follow "Person's fields"
    And I check "person_fields_lattes_url_active"
    And I check "person_fields_lattes_url_signup"
    And I follow "Save changes"
    Given I am on admin_user's control panel
    And the field lattes_url is public for all users
    When I follow "Informations" within "#section-profile"
    And I follow "Save"
    And I go to /profile/admin_user
    Then I should not see "Lattes"

  @selenium
  Scenario: Inform problem if the informed lattes doesn't exist
    And I check "Lattes Curriculum Plugin"
    And I follow "Save changes"
    And I go to /admin/features/manage_fields
    Given I follow "Person's fields"
    And I check "person_fields_lattes_url_active"
    And I check "person_fields_lattes_url_signup"
    And I follow "Save changes"
    Given I am on admin_user's control panel
    And the field lattes_url is public for all users
    When I follow "Informations" within "#section-profile"
    And I fill in "Lattes URL" with "http://lattes.cnpq.br/123456"
    And I follow "Save"
    And I go to /profile/admin_user#lattes_tab
    Then I should see "Lattes not found. Please, make sure the informed URL is correct."
