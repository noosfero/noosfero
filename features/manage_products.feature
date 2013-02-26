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

  Scenario: display "create new product" button
    Given I am logged in as "joaosilva"
    And I am on redemoinho's control panel
    When I follow "Manage Products and Services"
    Then I should see "New product or service"

  Scenario: paginate public listing products and services
    Given the following product_category
      | name |
      | Bicycle |
    And the following products
      | owner      | category |  name  | description |
      | redemoinho | bicycle  | Bike A | bicycle 1  |
      | redemoinho | bicycle  | Bike B | bicycle 2  |
      | redemoinho | bicycle  | Bike C | bicycle 3  |
      | redemoinho | bicycle  | Bike D | bicycle 4  |
      | redemoinho | bicycle  | Bike E | bicycle 5  |
      | redemoinho | bicycle  | Bike F | bicycle 6  |
      | redemoinho | bicycle  | Bike G | bicycle 7  |
      | redemoinho | bicycle  | Bike H | bicycle 8  |
      | redemoinho | bicycle  | Bike I | bicycle 9  |
      | redemoinho | bicycle  | Bike J | bicycle 10 |
      | redemoinho | bicycle  | Bike K | bicycle 11 |
    When I go to redemoinho's products page
    Then I should see "Bike A" within "#product-list"
    And I should see "Bike B" within "#product-list"
    And I should see "Bike C" within "#product-list"
    And I should see "Bike D" within "#product-list"
    And I should see "Bike E" within "#product-list"
    And I should see "Bike F" within "#product-list"
    And I should see "Bike G" within "#product-list"
    And I should see "Bike H" within "#product-list"
    And I should see "Bike I" within "#product-list"
    And I should not see "Bike J" within "#product-list"
    And I should not see "Bike K" within "#product-list"
    When I follow "Next"
    Then I should see "Bike J" within "#product-list"
    Then I should see "Bike K" within "#product-list"

  Scenario: listing products and services
    Given I am logged in as "joaosilva"
    And I am on redemoinho's control panel
    And I follow "Manage Products and Services"
    Then I should see "Listing products and services"

  Scenario: see button to back in categories hierarchy
    Given I am logged in as "joaosilva"
    And I am on redemoinho's control panel
    And I follow "Manage Products and Services"
    When I follow "New product or service"
    Then I should see "Back to the product listing" link

  Scenario: see toplevel categories
    Given the following product_categories
      | name |
      | Products |
      | Services |
    Given I am logged in as "joaosilva"
    And I go to redemoinho's new product page
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
    Given I am logged in as "joaosilva"
    And I go to redemoinho's new product page
    And I select "Products level0 »" from "category_id" within "#categories_container_level0"
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
    Given I am logged in as "joaosilva"
    And I go to redemoinho's new product page
    And I should not see /Computers level/
    And I select "Products level0 »" from "category_id" within "#categories_container_wrapper"
    And I should see /Computers level/
    And I should not see /Software develop/
    And I select "Services level0 »" from "category_id" within "#categories_container_wrapper"
    Then I should see /Software develop/
    And I should not see /Computers level/

  @selenium
  Scenario: show hierarchy of categories
    Given the following product_categories
      | name |
      | Products |
    And the following product_category
      | name | parent |
      | Computers | products |
    Given I am logged in as "joaosilva"
    And I go to redemoinho's new product page
    And I select "Products »" from "category_id" within "#categories_container_level0"
    And I select "Computers" from "category_id" within "#categories_container_level1"
    Then I should see "Products → Computers"

  @selenium
  Scenario: show links in hierarchy of categories and not link current category
    Given the following product_category
      | name |
      | Toplevel Product Categories |
    Given the following product_category
      | name | parent |
      | Category Level 1 | toplevel-product-categories |
    Given I am logged in as "joaosilva"
    And I go to redemoinho's new product page
    And I select "Toplevel Product Categories »" from "category_id" within "#categories_container_level0"
    And I select "Category Level 1" from "category_id" within "#categories_container_level1"
    Then I should see "Toplevel Product Categories" link
    And I should not see "Category Level 1" link

  @selenium
  Scenario: save button come initialy disabled
    Given the following product_category
      | name |
      | Only for test |
    And I am logged in as "joaosilva"
    When I go to redemoinho's new product page
    Then the "#save_and_continue" button should be disabled

  @selenium
  Scenario: enable save button when select one category
    Given I am logged in as "joaosilva"
    And the following product_category
      | name |
      | Browsers (accept categories) |
    When I go to redemoinho's new product page
    And I select "Browsers (accept categories)" from "category_id" within "#categories_container_wrapper"
    Then the "#save_and_continue" button should be enabled

  @selenium
  Scenario: dont enable save button when select category with not accept products
    Given the following product_category
      | name | accept_products |
      | Browsers | false |
    Given I am logged in as "joaosilva"
    When I go to redemoinho's new product page
    And I select "Browsers" from "category_id" within "#categories_container_wrapper"
    Then the "#save_and_continue" button should be disabled

  @selenium
  Scenario: save product
    Given the following product_category
      | name |
      | Bicycle |
    Given I am logged in as "joaosilva"
    When I go to redemoinho's new product page
    And I select "Bicycle" from "category_id" within "#categories_container_wrapper"
    And I press "Save and continue"
    When I go to redemoinho's products page
    And I follow "Bicycle" within "#product-list"
    Then I should see "Bicycle" within "#show_product"
    And I should see "Change category"

  Scenario: a user with permission can see edit links
    Given the following product_category
      | name |
      | Bicycle |
    And the following products
      | owner      | category | name | description |
      | redemoinho | bicycle  | Bike | Red bicycle |
    And I am logged in as "joaosilva"
    When I go to Rede Moinho's page of product Bike
    Then I should see "Change category"
    And I should see "Edit name"
    And I should see "Edit description"
    And I should see "Change image"

  Scenario: an allowed user will see a different button when has no description
    Given the following product_category
      | name |
      | Bicycle |
    And the following products
      | owner      | category | name |
      | redemoinho | bicycle  | Bike |
    And I am logged in as "joaosilva"
    When I go to Rede Moinho's page of product Bike
    Then I should see "Change category"
    And I should see "Edit name"
    And I should see "Add some description to your product"
    And I should see "Add price and other basic information"
    And I should see "Change image"

  Scenario: an allowed user will see a different button when has no basic info
    Given the following product_category
      | name |
      | Bicycle |
    And the following products
      | owner      | category | name |
      | redemoinho | bicycle  | Bike |
    And I am logged in as "joaosilva"
    When I go to Rede Moinho's page of product Bike
    Then I should see "Change category"
    And I should see "Edit name"
    And I should see "Add price and other basic information"
    And I should see "Change image"

  Scenario: a not logged user cannot see edit links
    Given I am not logged in
    And the following product_category
      | name |
      | Bicycle |
    And the following products
      | owner      | category | name | description |
      | redemoinho | bicycle  | Bike | Red bicycle |
    When I go to Rede Moinho's page of product Bike
    Then I should not see "Change category"
    And I should not see "Edit name"
    And I should not see "Edit description"
    And I should not see "Edit basic information"
    And I should not see "Change image"

  Scenario: a not allowed user cannot see edit links
    Given the following users
      | login       | name         |
      | mariasantos | Maria Santos |
    And the following product_category
      | name    |
      | Bicycle |
    And the following products
      | owner      | category | name | description |
      | redemoinho | bicycle  | Bike | Red bicycle |
    And I am logged in as "mariasantos"
    When I go to Rede Moinho's page of product Bike
    Then I should not see "Change category"
    And I should not see "Edit name"
    And I should not see "Edit description"
    And I should not see "Edit basic information"
    And I should not see "Change image"

  @selenium
  Scenario: edit name of a product
    Given the following product_category
      | name    |
      | Bicycle |
    And the following products
      | owner      | category | name |
      | redemoinho | bicycle  | Bike |
    And I am logged in as "joaosilva"
    When I go to Rede Moinho's page of product Bike
    And I follow "Edit name"
    And I fill in "Red bicycle" for "product_name"
    And I press "Save"
    Then I should see "Red bicycle"
    And I should be on Rede Moinho's page of product Red bicycle

  @selenium
  Scenario: cancel edition of a product name
    Given the following product_category
      | name |
      | Bicycle |
    And the following products
      | owner      | category | name |
      | redemoinho | bicycle  | Bike |
    And I am logged in as "joaosilva"
    When I go to Rede Moinho's page of product Bike
    And I follow "Edit name"
    When I follow "Cancel"
    Then I should see "Bike"

  @selenium
  Scenario: edit category of a product
    Given the following product_category
      | name |
      | Eletronics |
    And the following product_categories
      | name | parent |
      | Computers | eletronics |
      | DVDs      | eletronics |
    And the following products
      | owner      | category   | name       |
      | redemoinho | computers  | Generic pc |
    And I am logged in as "joaosilva"
    When I go to Rede Moinho's page of product Generic pc
    And I follow "Change category"
    And I select "Eletronics »" from "category_id" within "#categories_container_level0"
    Then I select "DVDs" from "category_id" within "#categories_container_level1"
    And I press "Save and continue"
    When I go to Rede Moinho's page of product Generic pc
    Then I should see "Eletronics → DVDs" within ".hierarchy-category"

  @selenium
  Scenario: cancel edition of a product category
    Given the following product_category
      | name |
      | Eletronics |
    And the following product_categories
      | name | parent |
      | Computers | eletronics |
      | DVDs      | eletronics |
    And the following products
      | owner      | category   | name       |
      | redemoinho | computers  | Generic pc |
    And I am logged in as "joaosilva"
    When I go to Rede Moinho's page of product Generic pc
    And I follow "Change category"
    When I follow "Back to product"
    Then I should see "Eletronics → Computers"


  @selenium
  Scenario: edit image of a product
    Given the following product_category
      | name |
      | Eletronics |
    And the following product_categories
      | name | parent |
      | Computers | eletronics |
      | DVDs      | eletronics |
    And the following products
      | owner      | category   | name       |
      | redemoinho | computers  | Generic pc |
    And I am logged in as "joaosilva"
    When I go to Rede Moinho's page of product Generic pc
    And I follow "Change image"
    When I follow "Cancel"
    Then I should be on Rede Moinho's page of product Generic pc

 # FIXME Not working because of tinyMCE plus selenium
 # @selenium
 # Scenario: edit description of a product
 #   Given the following product_category
 #     | name    |
 #     | Bicycle |
 #   And the following products
 #     | owner      | category | name | description       |
 #     | redemoinho | bicycle  | Bike | A new red bicycle |
 #   And I am logged in as "joaosilva"
 #   When I go to Rede Moinho's page of product Bike
 #   Then I should see "A new red bicycle"
 #   And I follow "Edit basic information"
 #   And I type in tinyMCE field "Description" the text "An used red bicycle"
 #   And I press "Save"
 #   Then I should not see "A new red bicycle"
 #   And I should see "An used red bicycle"
 #   And I should be on Rede Moinho's page of product Bike

  @selenium
  Scenario: cancel edition of a product description
    Given the following product_category
      | name |
      | Bicycle |
    And the following products
      | owner      | category | name | description       |
      | redemoinho | bicycle  | Bike | A new red bicycle |
    And I am logged in as "joaosilva"
    When I go to Rede Moinho's page of product Bike
    Then I should see "A new red bicycle"
    And I follow "Edit description"
    When I follow "Cancel"
    Then I should see "A new red bicycle"
    And I should be on Rede Moinho's page of product Bike

  @selenium
  Scenario: Edit product category and save without select any category
    Given the following product_category
      | name |
      | Eletronics |
    And the following product_category
      | name | parent |
      | Computers | eletronics |
    And the following products
      | owner      | category   | name       |
      | redemoinho | computers  | Generic pc |
    And I am logged in as "joaosilva"
    When I go to Rede Moinho's page of product Generic pc
    And I follow "Change category"
    And I press "Save and continue"
    Then I should not see "Product category can't be blank"
    When I go to Rede Moinho's page of product Generic pc
    Then I should see "Eletronics → Computers" within ".hierarchy-category"

    And I should see "Generic pc"

  @selenium
  Scenario: Scroll categories selection to right when editing
    Given the following product_category
      | name |
      | Eletronics |
    And the following product_category
      | name | parent |
      | Quantum Computers | eletronics |
    And the following product_category
      | name | parent |
      | Laptops from Mars | Quantum Computers |
    And the following product_category
      | name | parent |
      | Netbook from Venus | Laptops from Mars |
    And the following product_category
      | name | parent |
      | Nanonote nanotech with long name | Netbook from Venus |
    And the following products
      | owner      | category   | name       |
      | redemoinho | Nanonote nanotech with long name | Generic pc |
    And I am logged in as "joaosilva"
    When I go to Rede Moinho's page of product Generic pc
    And I follow "Change category"
    Then "Netbook from Venus" should be visible within "#categories_container_wrapper"

  @selenium
  Scenario: Truncate long category name in selection of category
    Given the following product_category
      | name |
      | Super Quantum Computers with teraflops |
      | Nanonote nanotech with long long name |
    And the following product_category
      | name | parent |
      | Netbook Quantum | Super Quantum Computers with teraflops |
    And I am logged in as "joaosilva"
    When I go to redemoinho's new product page
    Then I should see "Nanonote nanotech with long lo..."
    And I should see "Super Quantum Computers with t... »"

  @selenium
  Scenario: Edit unit of a product together your name
    Given the following product_category
      | name    |
      | Bicycle |
    And the following products
      | owner      | category | name |
      | redemoinho | bicycle  | Bike |
    And the following units
      | singular | plural |
      | Kilo     | Kilos  |
    And I am logged in as "joaosilva"
    When I go to Rede Moinho's page of product Bike
    And I follow "Edit name and unit"
    And I fill in "Red bicycle" for "product_name"
    And I select "Kilo" from "product_unit_id" within "#product-name-form"
    And I press "Save"
    Then I should see "Red bicycle - kilo"

  @selenium
  Scenario: Show info about unavailable product
    Given the following product_category
      | name    |
      | Bicycle |
    And the following products
      | owner      | category | name |
      | redemoinho | bicycle  | Bike |
    And I am logged in as "joaosilva"
    When I go to Rede Moinho's page of product Bike
    And I follow "Add price and other basic information"
    And I fill in "10" for "product_price"
    And I choose "No"
    And I press "Save"
    Then I should see "Product not available!"

  @selenium
  Scenario: Add and remove some qualifiers
    Given the following product_category
      | name    |
      | Bicycle |
    And the following products
      | owner      | category | name |
      | redemoinho | bicycle  | Bike |
    And the following qualifiers
      | name |
      | Organic |
    And the following certifiers
      | name | qualifiers |
      | Colivre | Organic |
    And I am logged in as "joaosilva"
    When I go to Rede Moinho's page of product Bike
    And I follow "Add price and other basic information"
    And I follow "Add new qualifier"
    And I select "Organic" from "selected_qualifier" within "#product-qualifiers-list"
    And I press "Save"
    And I go to Rede Moinho's page of product Bike
    Then I should see "Organic (Self declared)"
    When I follow "Edit basic information"
    And I follow "Delete qualifier"
    And I press "Save"
    And I go to Rede Moinho's page of product Bike
    Then I should not see "Organic (Self declared)"

  @selenium
  Scenario: Show checkbox to mark product as highlight
    Given the following product_category
      | name    |
      | Bicycle |
    And the following products
      | owner      | category | name |
      | redemoinho | bicycle  | Bike |
    And I am logged in as "joaosilva"
    When I go to Rede Moinho's page of product Bike
    And I follow "Add price and other basic information"
    Then I should see "Highlight this product?"
    And I check "Highlight this product?"
