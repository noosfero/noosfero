Feature: sitemap
  As a noosfero user
  I want to list articles

  Background:
    Given I am on the homepage
    And the following users
      | login | name |
      | joaosilva | Joao Silva |
    And the following files
      | owner   | file      | mime      |
      | joaosilva | AGENDA_CULTURA_-_FESTA_DE_VAQUEIROS_PONTO_DE_SERRA_PRETA_BAIXA.txt | text/plain |

  Scenario: view a folder page
    When I am on /profile/joaosilva/sitemap
    Then I should see "AGENDA_CULTURA_-_FESTA_DE_VAQUEIRO(...).txt"

  Scenario: view the CMS
    Given I am logged in as "joaosilva"
    When I am on /myprofile/joaosilva/cms
    Then I should see "AGENDA_CULTURA_-_FEST(...).txt"
