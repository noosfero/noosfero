Feature: import lattes information
  As an user
  I want to inform my lattes url address
  So that I can import my academic informations automatically

  Background:
    Given "LattesCurriculumPlugin" plugin is enabled
    And I am logged in as admin
    And I go to /admin/plugins
    And I check "Lattes Curriculum Plugin"
    And I press "Save changes"
    And I go to /admin/features/manage_fields
    Given I follow "Person's fields"
    And I check "person_fields_lattes_url_active"
    And I check "person_fields_lattes_url_signup"
    And I press "save_person_fields"

  Scenario: Don't accept edit the profile with invalid lattes url
    Given I am on admin_user's control panel
    When I follow "Edit Profile"
    And I fill in "Lattes URL" with "http://youtube.com.br/"
    And I press "Save"
    Then I should see "Academic info lattes url is invalid"

  Scenario: Import lattes informations
    Given I am on admin_user's control panel
    And the field lattes_url is public for all users
    When I follow "Edit Profile"
    And I fill in "Lattes URL" with "http://lattes.cnpq.br/2864976228727880"
    And I press "Save"
    And I go to /profile/admin_user#lattes_tab
    Then I should see "Endereço para acessar este CV: http://lattes.cnpq.br/2864976228727880"

  Scenario: Don't show lattes informations for blank lattes urls
    Given I am on admin_user's control panel
    And the field lattes_url is public for all users
    When I follow "Edit Profile"
    And I press "Save"
    And I go to /profile/admin_user
    Then I should not see "Lattes"

  Scenario: Inform problem if the informed lattes doesn't exist
    Given I am on admin_user's control panel
    And the field lattes_url is public for all users
    When I follow "Edit Profile"
    And I fill in "Lattes URL" with "http://lattes.cnpq.br/123456"
    And I press "Save"
    And I go to /profile/admin_user#lattes_tab
    Then I should see "Lattes not found. Please, make sure the informed URL is correct."