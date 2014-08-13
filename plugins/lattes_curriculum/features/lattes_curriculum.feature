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
    And I am not logged in 

  @selenium
  Scenario: Import lattes informations after singup
    Given I am on signup page
    And I fill in "e-Mail" with "josesilva@example.com"
    And I fill in "Username" with "josesilva"
    And I fill in "Full name" with "João Silva"
    And I fill in "Password" with "secret"
    And I fill in "Password confirmation" with "secret"
    And I fill in "URL Lattes" with "http://lattes.cnpq.br/2864976228727880"
    And wait for the captcha signup time
    And I press "Create my account"