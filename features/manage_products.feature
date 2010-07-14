Feature: manage products
  As an enterprise owner
  I want to manage my products

  Background:
    Given the following users
      | login | name |
      | joaosilva | Joao Silva |
    And the following enterprises
      | identifier | owner | name | enabled |
      | redemoinho | joaosilva | Rede Moinho | true |
    And feature "disable_products_for_enterprises" is disabled on environment
    And I am logged in as "joaosilva"
    And I am on Rede Moinho's control panel
    And I follow "Manage Products and Services"

  Scenario: listing products and services
    Then I should see "Listing products and services"

  Scenario: see toplevel categories
    Given the following product_categories
      | name |
      | Products |
      | Services |
    When I follow "New product or service"
    Then I should see "Products"
    And I should see "Service"

  @selenium
  Scenario: select a toplevel category and see subcategories
    Given the following product_categories
      | name |
      | Products level0 |
    And the following product_categories
      | name | parent |
      | Computers level1 | products-level0 |
      | DVDs level1 | products-level0 |
    When I follow "New product or service"
    And I select "Products level0 »"
    Then I should see "Computers level1"
    And I should see "DVDs level1"

  @selenium
  Scenario: hide subcategories when select other toplevel category
    Given the following product_categories
      | name |
      | Products level0 |
      | Services level0 |
    And the following product_categories
      | name | parent |
      | Computers level1 | products-level0 |
      | Software development level1 | services-level0 |
    When I follow "New product or service"
    And I select "Products level0 »"
    And I select "Computers level1"
    And I select "Services level0 »"
    Then I should see "Software development level1"
    And I should not see "Computers level1"

  @selenium
  Scenario: show hierarchy of categories
    Given the following product_categories
      | name |
      | Products |
    And the following product_category
      | name | parent |
      | Computers | products |
    When I follow "New product or service"
    And I select "Products »"
    And I select "Computers"
    Then I should see "Products → Computers"

  @selenium
  Scenario: show links in hierarchy of categories and not link current category
    Given the following product_category
      | name |
      | Toplevel Product Categories |
    Given the following product_category
      | name | parent |
      | Category Level 1 | toplevel-product-categories |
    When I follow "New product or service"
    And I select "Toplevel Product Categories »"
    And I select "Category Level 1"
    Then I should see "Toplevel Product Categories" link
    And I should not see "Category Level 1" link

  @selenium
  Scenario: save button come initialy disabled
    Given the following product_category
      | name |
      | Only for test |
    When I go to /myprofile/redemoinho/manage_products/new
    Then the "#save_and_continue" button should not be enabled

  @selenium
  Scenario: enable save button when select one category
    Given the following product_category
      | name |
      | Browsers (accept categories) |
    When I follow "New product or service"
    And I select "Browsers (accept categories)"
    Then the "Save and continue" button should be enabled

  @selenium
  Scenario: dont enable save button when select category with not accept products
    Given the following product_category
      | name | accept_products |
      | Browsers | false |
    When I follow "New product or service"
    And I select "Browsers"
    Then the "#save_and_continue" button should not be enabled

  @selenium
  Scenario: save product
    Given the following product_category
      | name |
      | Bicycle |
    When I follow "New product or service"
    And I select "Bicycle"
    And I press "Save and continue"
    Then I should see "Category: Bicycle"

  @selenium
  Scenario: stay on the same place after error on save
    Given the following product_category
      | name |
      | Bicycle |
    And I follow "New product or service"
    And I select "Bicycle"
    And I press "Save and continue"
    When I follow "Back"
    And I follow "New product or service"
    And I select "Bicycle"
    And I press "Save and continue"
    Then I should be on Rede Moinho's new product page
    And I should see "Bicycle"
