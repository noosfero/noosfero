Feature: import lattes information
  As an user
  I want to inform my lattes url address
  So that I can import my academic informations automatically

  Background:
    Given "LattesCurriculumPlugin" plugin is enabled
    And I am logged in as admin
    And I go to /admin/plugins
    And I check "LattesCurriculumPlugin"
    And I press "Save changes"
    And I go to /admin/features/manage_fields
    Given I follow "Person's fields"
    And I check "person_fields_lattes_url_active"
    And I check "person_fields_lattes_url_signup"
    And I press "save_person_fields"
    And feature "skip_new_user_email_confirmation" is enabled on environment
    And I am not logged in 

  @selenium
  Scenario: Import lattes informations after singup
    Given I am on signup page
    When I fill in "e-Mail" with "josesilva@example.com"
    And I fill in "Username" with "josesilva"
    And I fill in "Full name" with "João Silva"
    And I fill in "Password" with "secret"
    And I fill in "Password confirmation" with "secret"
    And I fill in "Lattes URL" with "http://lattes.cnpq.br/2864976228727880"
    And wait for the captcha signup time
    And I press "Create my account"
    And I go to /profile/josesilva
    And I follow "Lattes" within "#ui-tabs-anchor"
    Then I should see "Endereço para acessar este CV: http://lattes.cnpq.br/2864976228727880"

  @selenium
  Scenario: Don't show lattes informations for blank lattes urls
    Given I am on signup page
    When I fill in "e-Mail" with "josesilva@example.com"
    And I fill in "Username" with "josesilva"
    And I fill in "Full name" with "João Silva"
    And I fill in "Password" with "secret"
    And I fill in "Password confirmation" with "secret"
    And wait for the captcha signup time
    And I press "Create my account"
    And I go to /profile/josesilva
    Then I should not see "Lattes" within "#ui-tabs-anchor"

  @selenium
  Scenario: Inform problem if the informed lattes doesn't exist
    Given I am on signup page
    When I fill in "e-Mail" with "josesilva@example.com"
    And I fill in "Username" with "josesilva"
    And I fill in "Full name" with "João Silva"
    And I fill in "Password" with "secret"
    And I fill in "Password confirmation" with "secret"
    And I fill in "Lattes URL" with "http://lattes.cnpq.br/123456"
    And wait for the captcha signup time
    And I press "Create my account"
    And I go to /profile/josesilva
    And I follow "Lattes" within "#ui-tabs-anchor"
    Then I should see "Lattes not found. Please, make sure the informed URL is correct."