Feature: activate enterprise
  As an enterprise owner
  I want to activate my enterprise
  In order to publish content

  Background:
    Given the following users
      | login | name |
      | joaosilva | Joao Silva |
    And I am logged in as "joaosilva"

  Scenario: added an unexistent code
    Given feature "enterprise_activation" is enabled on environment
    And I am on Joao Silva's control panel
    And I fill in "Enterprise activation code" with "abcde"
    When I press "Activate"
    Then I should see "Invalid enterprise code"

  Scenario: added a code from an activated enterprise
    Given feature "enterprise_activation" is enabled on environment
    And the following enterprises
      | identifier | name | enabled |
      | products-factory | Products Factory | false |
    And I am on Joao Silva's control panel
    And enterprise "Products Factory" is enabled
    And I fill in "Enterprise activation code" with code of "Products Factory"
    When I press "Activate"
    Then I should see "This enterprise is already active"

  Scenario: added a code from an enterprise with no foundation year or cnpj
    Given feature "enterprise_activation" is enabled on environment
    And the following enterprises
      | identifier | name | enabled |
      | products-factory | Products Factory | false |
    And I am on Joao Silva's control panel
    And I fill in "Enterprise activation code" with code of "Products Factory"
    When I press "Activate"
    Then I should see "We don't have enough information about your enterprise to identify you."
    And enterprise "Products Factory" should not be blocked

  Scenario: filled activation question with wrong foundation year
    Given feature "enterprise_activation" is enabled on environment
    And the following enterprises
      | identifier | name | enabled | foundation_year |
      | services-provider | Services Provider | false | 2000 |
    And I am on Joao Silva's control panel
    And I fill in "Enterprise activation code" with code of "Services Provider"
    And I press "Activate"
    And I fill in "What year your enterprise was founded? It must have 4 digits, eg 1990." with "1999"
    When I press "Continue"
    Then I should see "There was a failed atempt of activation and the automated activation was disabled for your security."
    And enterprise "Services Provider" should be blocked

  Scenario: filled activation question with wrong cnpj
    Given feature "enterprise_activation" is enabled on environment
    And the following enterprises
      | identifier | name | enabled | cnpj |
      | services-provider | Services Provider | false | 94.132.024/0001-48 |
    And I am on Joao Silva's control panel
    And I fill in "Enterprise activation code" with code of "Services Provider"
    And I press "Activate"
    And I fill in "What is the CNPJ of your enterprise?" with "12345678912345"
    When I press "Continue"
    Then I should see "There was a failed atempt of activation and the automated activation was disabled for your security."
    And enterprise "Services Provider" should be blocked

  @selenium
  Scenario: activate succesffuly an enterprise with foundation_year
    Given feature "enterprise_activation" is enabled on environment
    And the following enterprises
      | identifier | name | enabled | foundation_year |
      | services-provider | Services Provider | false | 2000 |
    And I visit "Joao Silva's control panel" and wait
    And I fill in "Enterprise activation code" with code of "Services Provider"
    And I press "Activate" and wait
    And I fill in "What year your enterprise was founded? It must have 4 digits, eg 1990." with "2000"
    And I press "Continue"
    And I check "I read the terms of use and accepted them"
    When I press "Continue"
    Then I should see "Services Provider was successfuly activated. Now you may go to your control panel or to the control panel of your enterprise"
    And enterprise "Services Provider" should be enabled
    And "Joao Silva" is admin of "Services Provider"

  @selenium
  Scenario: replace template after enable an enterprise
    Given enterprise template must be replaced after enable
    And feature "enterprise_activation" is enabled on environment
    And the following enterprises
      | identifier | name | enabled | foundation_year |
      | services-provider-2 | Services Provider 2 | false | 2000 |
      | active-template | Active Template | false | 2000 |
    And "Active Template" is the active enterprise template
    And "Services Provider 2" doesnt have "Active Template" as template
    And I visit "Joao Silva's control panel" and wait
    And I fill in "Enterprise activation code" with code of "Services Provider 2"
    And I press "Activate" and wait
    And I fill in "What year your enterprise was founded? It must have 4 digits, eg 1990." with "2000"
    And I press "Continue"
    And I check "I read the terms of use and accepted them"
    When I press "Continue"
    Then I should see "Services Provider 2 was successfuly activated. Now you may go to your control panel or to the control panel of your enterprise"
    And enterprise "Services Provider 2" should be enabled
    And "Joao Silva" is admin of "Services Provider 2"
    And "Services Provider 2" has "Active Template" as template

  @selenium
  Scenario: not replace template after enable an enterprise
    Given enterprise template must not be replaced after enable
    And feature "enterprise_activation" is enabled on environment
    And the following enterprises
      | identifier | name | enabled | foundation_year |
      | services-provider-3 | Services Provider 3 | false | 2000 |
      | active-template | Active Template | false | 2000 |
    And "Active Template" is the active enterprise template
    And "Services Provider 3" doesnt have "Active Template" as template
    When I visit "Joao Silva's control panel" and wait
    And I fill in "Enterprise activation code" with code of "Services Provider 3"
    And I press "Activate" and wait
    And I fill in "What year your enterprise was founded? It must have 4 digits, eg 1990." with "2000"
    And I press "Continue"
    And I check "I read the terms of use and accepted them"
    When I press "Continue"
    Then I should see "Services Provider 3 was successfuly activated. Now you may go to your control panel or to the control panel of your enterprise"
    And enterprise "Services Provider 3" should be enabled
    And "Joao Silva" is admin of "Services Provider 3"
    And "Services Provider 3" doesnt have "Active Template" as template
