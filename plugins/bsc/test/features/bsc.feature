Feature: bsc

  Background:
    Given "Bsc" plugin is enabled

  Scenario: display link to bsc creation on admin panel when bsc plugin active
    Given I am logged in as admin
    When I am on the environment control panel
    Then I should see "Create Bsc"
    When "Bsc" plugin is disabled
    And I am on the environment control panel
    Then I should not see "Create Bsc"

  Scenario: be able to create a bsc
    Given I am logged in as admin
    And I am on the environment control panel
    And I follow "Create Bsc"
    And I fill in the following:
      | Business name | Sample Bsc         |
      | Company name  | Sample Bsc         |
      | profile_data_identifier    | sample-identifier  |
      | Cnpj          | 07.970.746/0001-77 |
    When I press "Save"
    Then there should be a profile named "Sample Bsc"

  Scenario: display a button on bsc control panel to manage associated enterprises
    Given the folllowing "bsc" from "bsc_plugin"
      | business_name | identifier | company_name  | cnpj               |
      | Bsc Test      | bsc-test   | Bsc Test Ltda | 94.132.024/0001-48 |
    And I am logged in as admin
    When I am on Bsc Test's control panel
    Then I should see "Manage associated enterprises"

  Scenario: display a button on bsc control panel to transfer ownership
    Given the folllowing "bsc" from "bsc_plugin"
      | business_name | identifier | company_name  | cnpj               |
      | Bsc Test      | bsc-test   | Bsc Test Ltda | 94.132.024/0001-48 |
    And I am logged in as admin
    When I am on Bsc Test's control panel
    Then I should see "Transfer ownership"

  Scenario: create a new enterprise already associated with a bsc
    Given the following user
      | login       | name        |
      | pedro-silva | Pedro Silva |
    And the folllowing "bsc" from "bsc_plugin"
      | business_name | identifier | company_name  | cnpj               | owner       |
      | Bsc Test      | bsc-test   | Bsc Test Ltda | 94.132.024/0001-48 | pedro-silva |
    And organization_approval_method is "none" on environment
    And I am logged in as "pedro-silva"
    And I am on Bsc Test's control panel
    And I follow "Manage associated enterprises"
    And I follow "Add new enterprise"
    And I fill in the following:
      | Name    | Associated Enterprise |
      | Address | associated-enterprise |
    When I press "Save"
    Then "Associated Enterprise" should be associated with "Bsc Test"

  Scenario: do not display "add new product" button
    Given the following user
      | login       | name        |
      | pedro-silva | Pedro Silva |
    And the folllowing "bsc" from "bsc_plugin"
      | business_name | identifier | company_name  | cnpj               | owner       |
      | Bsc Test      | bsc-test   | Bsc Test Ltda | 94.132.024/0001-48 | pedro-silva |
    And feature "disable_products_for_enterprises" is disabled on environment
    And I am logged in as "pedro-silva"
    And I am on Bsc Test's control panel
    When I follow "Manage Products and Services"
    Then I should not see "New product or service"

  Scenario: display bsc's enterprises' products name on the bsc catalog
    Given the following user
      | login       | name        |
      | pedro-silva | Pedro Silva |
    And the folllowing "bsc" from "bsc_plugin"
      | business_name | identifier | company_name  | cnpj               | owner       |
      | Bsc Test      | bsc-test   | Bsc Test Ltda | 94.132.024/0001-48 | pedro-silva |
    And the following enterprise
      | identifier        | name              |
      | sample-enterprise | Sample Enterprise |
    And the following product_category
      | name |
      | bike |
    And the following products
      | owner             | category  | name          |
      | sample-enterprise | bike      | Master Bike   |
    And "Sample Enterprise" is associated with "Bsc Test"
    And I am logged in as "pedro-silva"
    When I go to Bsc Test's products page
    Then I should see "Master Bike"
    And I should see "Sample Enterprise"

  Scenario: display enterprise name linked only if person is member of any Bsc
    Given the folllowing "bsc" from "bsc_plugin"
      | business_name | identifier    | company_name          | cnpj               |
      | Bsc Test      | bsc-test      | Bsc Test Ltda         | 94.132.024/0001-48 |
      | Another Bsc   | another-bsc   | Another Bsc Test Ltda | 07.970.746/0001-77 |
    And the following enterprise
      | identifier        | name              |
      | sample-enterprise | Sample Enterprise |
    And the following product_category
      | name |
      | bike |
    And the following products
      | owner             | category  | name          |
      | sample-enterprise | bike      | Master Bike   |
    And "Sample Enterprise" is associated with "Bsc Test"
    And the folllowing "bsc" from "bsc_plugin"
      | business_name | identifier    | company_name          | cnpj               |
    And the following user
      | login | name        |
      | pedro | Pedro Souto |
      | maria | Maria Souto |
    And pedro is member of another-bsc
    And I am logged in as "pedro"
    When I go to Bsc Test's products page
    Then I should see "Sample Enterprise"
    And I should see "Sample Enterprise" within "a.bsc-catalog-enterprise-link"
    But I am logged in as "maria"
    When I go to Bsc Test's products page
    Then I should see "Sample Enterprise"
    #TODO -> test that it's not a link

  Scenario: allow only environment administrators to delete bsc profile
    Given the folllowing "bsc" from "bsc_plugin"
      | business_name | identifier | company_name  | cnpj               |
      | Bsc Test      | bsc-test   | Bsc Test Ltda | 94.132.024/0001-48 |
    And the following user
      | login | name        |
      | pedro | Pedro Souto |
    And "Pedro Souto" is admin of "Bsc Test"
    And I am logged in as "pedro"
    And I am on Bsc Test's control panel
    And I follow "Bsc info and settings"
    When I follow "Delete profile"
    Then I should see "Access denied"
    And "Bsc Test" profile should exist
    But I am logged in as admin
    And I am on Bsc Test's control panel
    And I follow "Bsc info and settings"
    When I follow "Delete profile"
    Then I should see "Deleting profile Bsc Test"
    And I follow "Yes, I am sure"
    Then "Bsc Test" profile should not exist

  # Like we can believe that selenium is going to work...
  @selenium
  Scenario: list already associated enterprises on manage associated enterprises
    Given the folllowing "bsc" from "bsc_plugin"
      | business_name | identifier | company_name  | cnpj               |
      | Bsc Test      | bsc-test   | Bsc Test Ltda | 94.132.024/0001-48 |
    And the following enterprises
      | identifier    | name          |
      | enterprise-1  | Enterprise 1  |
      | enterprise-2  | Enterprise 2  |
    And "Enterprise 1" is associated with "Bsc Test"
    And "Enterprise 2" is associated with "Bsc Test"
    And I am logged in as admin
    And I am on Bsc Test's control panel
    When I follow "Manage associated enterprises"
    Then I should see "Enterprise 1"
    And I should see "Enterprise 2"
