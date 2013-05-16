Feature: Bsc contract
As a Bsc admin
I would like to register a contract
In order to make negotiations

  Background:
    Given "Bsc" plugin is enabled
    And the folllowing "bsc" from "bsc_plugin"
      | business_name | identifier | company_name  | cnpj               |
      | Bsc Test      | bsc-test   | Bsc Test Ltda | 94.132.024/0001-48 |
    And I am logged in as admin

  Scenario: be able see the manage contracts button only if the profile is a Bsc
    Given the following community
      | name              | identifier        |
      | Sample Community  | sample-community  |
    When I am on Sample Community's control panel
    Then I should not see "Manage contracts"
    But I am on Bsc Test's control panel
    Then I should see "Manage contracts"

