Feature: browse catalogs
  As a noosfero visitor
  I want to browse catalogs of products

  Background:
    Given the following users
      | login     | name       |
      | joaosilva | Joao Silva |
    And the following enterprises
      | identifier | owner     | name                               | enabled |
      | artebonito | joaosilva | Associação de Artesanato de Bonito | true    |
    And feature "products_for_enterprises" is enabled on environment
    And the following product_categories
      | name   |
      | categ1 |
      | food   |
    And I am on /catalog/artebonito

  Scenario: display titles
    Then the page title should be "Associação de Artesanato de Bonito"
    And I should see "Products/Services"

  Scenario: display the simplest possible product
    Given the following products
      | owner      | category |
      | artebonito | categ1   |
    And I am on /catalog/artebonito
    Then I should see "categ1" within "li.product-link"
    And I should see "No image" within ".no-image"
    And I should not see "unit" within "#product-list"
    And I should not see "product unavailable"
    And I should not see "description"
    And I should not see "qualifiers"
    And I should not see "price composition"

  Scenario: display a simple product without price
    Given the following products
      | owner      | category | name     |
      | artebonito | categ1   | Produto1 |
    And I am on /catalog/artebonito
    Then I should see "Produto1" within "li.product-link"
    And I should see "No image" within ".no-image"
    And I should not see "unit" within "#product-list"
    And I should not see "product unavailable"
    And I should not see "description"
    And I should not see "qualifiers"
    And I should not see "price composition"

  Scenario: display a simple product without details
    Given the following products
      | owner      | category | name     | price |
      | artebonito | categ1   | Produto1 | 50.00 |
    And I am on /catalog/artebonito
    Then I should see "Produto1" within "li.product-link"
    And I should see "50.00" within "span.product-price"
    And I should see "unit" within "span.product-unit"
    And I should see "No image" within ".no-image"
    And I should not see "product unavailable"
    And I should not see "description"
    And I should not see "qualifiers"
    And I should not see "price composition"

  Scenario: don't display the price when it's $0.00
    Given the following products
      | owner      | category | name     | price |
      | artebonito | categ1   | Produto1 | 0.00 |
    And I am on /catalog/artebonito
    Then I should see "Produto1" within "li.product-link"
    And I should not see "0.00"

  Scenario: don't display the price when it's not defined
    Given the following products
      | owner      | category | name     |
      | artebonito | categ1   | Produto1 |
    And I am on /catalog/artebonito
    Then I should see "Produto1" within "li.product-link"
    And I should not see "0.00"
    And I should see "No image" within ".no-image"
    And I should not see "product unavailable"
    And I should not see "description"
    And I should not see "qualifiers"
    And I should not see "price composition"

  Scenario: product name links to product page
    Given the following products
      | owner      | category | name     | price |
      | artebonito | categ1   | Produto1 | 50.00 |
    And I am on /catalog/artebonito
    When I follow "Produto1" within "li.product-link"
    Then I should be taken to "Produto1" product page

  Scenario: display product with custom image
    Given the following products
      | owner      | category | name    | price | img     |
      | artebonito | categ1   | Agrotox | 12.34 | agrotox |
    And I am on /catalog/artebonito
    Then I should see "Agrotox" within "li.product-link"
    And I should see "12.34" within "span.product-price"
    And I should see "unit" within "span.product-unit"
    And I should not see "No image"
    And I should not see "product unavailable"
    And I should not see "description"
    And I should not see "qualifiers"
    And I should not see "price composition"

  Scenario: display "zoom in" button
    Given the following products
      | owner      | category | name    | price | img     |
      | artebonito | categ1   | Agrotox | 12.34 | agrotox |
    And I am on /catalog/artebonito
    And I should not see "No image"
    And I should see "Zoom in" within ".zoomify-image"

  Scenario: image links to product page
    Given the following products
      | owner      | category | name    | price | img     |
      | artebonito | categ1   | Agrotox | 12.34 | agrotox |
    And I am on /catalog/artebonito
    When I follow "Agrotox" within ".product-image-link"
    Then I should be taken to "Agrotox" product page

  Scenario: display product with discount
    Given the following products
      | owner      | category | name        | price | discount | img         |
      | artebonito | categ1   | Semterrinha | 99.99 | 12.34    | semterrinha |
    And I am on /catalog/artebonito
    Then I should see "Semterrinha" within "li.product-link"
    And I should see "99.99" within "span.product-discount"
    And I should see "87.65" within "span.product-price"
    And I should not see "No image"
    And I should not see "description"
    And I should not see "qualifiers"
    And I should not see "price composition"

  @selenium-fixme
  Scenario: display description button when needed (but not the description)
    Given the following products
      | owner      | category | name     | price | description                                           |
      | artebonito | categ1   | Produto2 | 12.34 | A small description for a product that doesn't exist. |
    And I am on /catalog/artebonito
    And I reload and wait for the page
    Then I should see "Produto2" within "li.product-link"
    And I should see "12.34" within "span.product-price"
    And I should see "description" within "#product-description-button"
    And "description" should not be visible within "product-description-button"
    And I should see "A small description" within "#product-description"
    And "A small description for a product that doesn't exist" should not be visible within "product-description"

  @selenium-fixme
  Scenario: display description when button is clicked
    Given the following products
      | owner      | category | name     | price | description                                           |
      | artebonito | categ1   | Produto3 | 12.34 | A small description for a product that doesn't exist. |
    And I am on /catalog/artebonito
    And I reload and wait for the page
    When I follow "product-description-button"
    Then I should see "A small description" within "#product-description"
    And "A small description for a product that doesn't exist" should not be visible within "product-description"

  @selenium-fixme
  Scenario: hide description
    Given the following products
      | owner      | category | name     | price | description                                           |
      | artebonito | categ1   | Produto3 | 12.34 | A small description for a product that doesn't exist. |
    And I am on /catalog/artebonito
    And I reload and wait for the page
    When I click "product-description-button"
    Then I should see "A small description" within "#product-description"
    And the "product-description" should be visible
    When I click "product-list"
    Then the "product-description" should not be visible

  Scenario: display unavailable product
    Given the following products
      | owner      | category | name  | price | available |
      | artebonito | categ1   | Prod3 | 12.34 | false     |
    And I am on /catalog/artebonito
    Then I should see "Prod3" within "li.not-available"
    And I should see "12.34" within "li.not-available"
    And I should see "product unavailable" within "li.product-unavailable"
    And I should not see "qualifiers"
    And I should not see "price composition"

  Scenario: display qualifiers
    Given the following qualifiers
      | name    |
      | Organic |
    And the following certifiers
      | name    | qualifiers |
      | Colivre | Organic    |
    And the following products
      | owner      | category | name   | price | qualifier |
      | artebonito | categ1   | Banana | 0.99  | Organic   |
    And I am on /catalog/artebonito
    Then I should see "Banana" within "li.product-link"
    And I should see "0.99" within "span.product-price"
    And I should see "qualifiers" within "li.product-qualifiers"
    And I should see "Organic" within "span.search-product-qualifier"
    And I should not see "price composition"

  @selenium-fixme
  Scenario: not display price composition button if price is not described
    Given the following product
      | owner      | category | name     | price |
      | artebonito | food     | Bananada | 10.00 |
    And the following input
      | product  | category | price_per_unit | amount_used |
      | Bananada | food     | 0.99           | 5           |
    And I am on /catalog/artebonito
    And I reload and wait for the page
    Then I should see "Bananada" within "li.product-link"
    And I should see "10.00" within "span.product-price"
    And the "#product-price-composition-button" should not be visible

  @selenium-fixme
  Scenario: display price composition button (but not inputs)
    Given the following product
      | owner      | category | name     | price |
      | artebonito | food     | Bananada | 10.00 |
    And the following input
      | product  | category | price_per_unit | amount_used |
      | Bananada | food     | 2.00           | 5           |
    And I am on /catalog/artebonito
    And I reload and wait for the page
    Then I should see "Bananada" within "li.product-link"
    And I should see "10.00" within "span.product-price"
    And I should see "price composition" within "#product-price-composition-button"
    And the "#product-price-composition-button" should be visible
    And I should see "food" within "#product-price-composition"
    And I should see "10.00" within "#product-price-composition"

  @selenium-fixme
  Scenario: display price composition when button is clicked
    Given the following product
      | owner      | category | name     | price |
      | artebonito | food     | Bananada | 10.88 |
    And the following input
      | product  | category | price_per_unit | amount_used |
      | Bananada | food     | 2.72           | 4           |
    And I am on /catalog/artebonito
    And I reload and wait for the page
    When I click "#product-price-composition-button"
    Then the "#product-price-composition" should be visible
    And I should see "food" within "#product-price-composition"
    And I should see "10.88" within "#product-price-composition"

  @selenium-fixme
  Scenario: display inputs and raw materials button when not completely filled
    Given the following product
      | owner      | category | name     | price |
      | artebonito | food     | Vitamina | 17.99 |
    And the following unit
      | name  | plural |
      | Liter | Liters |
    And the following input
      | product  | category |
      | Vitamina | food     |
    And I am on /catalog/artebonito
    And I reload and wait for the page
    Then the "#inputs-button" should be visible
    And I should see "inputs and raw materials" within "#inputs-button"

  @selenium-fixme
  Scenario: display inputs and raw materials button
    Given the following product
      | owner      | category | name     | price |
      | artebonito | food     | Vitamina | 17.99 |
    And the following unit
      | name  | plural |
      | Liter | Liters |
    And the following input
      | product  | category | price_per_unit | amount_used | unit  |
      | Vitamina | food     | 1.45           | 7           | Liter |
    And I am on /catalog/artebonito
    And I reload and wait for the page
    Then I should see "Vitamina" within "li.product-link"
    And I should see "17.99" within "span.product-price"
    And the "#inputs-button" should be visible
    And I should see "inputs and raw materials" within "#inputs-button"
    And the "#inputs-description" should not be visible
    And I should see "7.0 Liter of food" within "#inputs-description"

  @selenium-fixme
  Scenario: display inputs and raw materials description
    Given the following product
      | owner      | category | name     | price |
      | artebonito | food     | Vitamina | 17.99 |
    And the following unit
      | name  | plural |
      | Liter | Liters |
    And the following input
      | product  | category | price_per_unit | amount_used | unit  |
      | Vitamina | food     | 1.45           | 7           | Liter |
    And I am on /catalog/artebonito
    And I reload and wait for the page
    When I click "#inputs-button"
    Then the "#inputs-description" should be visible
    And I should see "7.0 Liter of food" within "#inputs-description"

  @selenium-fixme
  Scenario: hide inputs and raw materials
    Given the following product
      | owner      | category | name     | price |
      | artebonito | food     | Vitamina | 17.99 |
    And the following unit
      | name  | plural |
      | Liter | Liters |
    And the following input
      | product  | category | price_per_unit | amount_used | unit  |
      | Vitamina | food     | 1.45           | 7           | Liter |
    And I am on /catalog/artebonito
    And I reload and wait for the page
    When I click "#inputs-button"
    Then the "#inputs-description" should be visible
    And I should see "7.0 Liter of food" within "#inputs-description"
    When I click "#product-list"
    Then the "#inputs-description" should not be visible
