# These tests were originally unit tests, but they were moved here since they are view tests. The originals have been kept just in case somebody wants to review them, but should be removed shortly.

Feature: enterprise homepage
  As a noosfero visitor
  I want to browse an enterprise's homepage
  In order to know more information about the enterprise

  Background:
    Given the following users
      | login       | name         |
      | durdentyler | Tyler Durden |
    And the following enterprises
      | identifier | owner       | name                  | contact_email        | contact_phone  | enabled |
      | mayhem     | durdentyler | Paper Street Soap Co. | queen@workerbees.org | (288) 555-0153 | true    |
    And the following enterprise homepage
      | enterprise | name             |
      | mayhem     | article homepage |
    And the following product_category
      | name |
      | soap |
    And the following product
      | name             | category | owner  |
      | Natural Handmade | soap     | mayhem |    


#  should 'display profile info' do
#    e = Enterprise.create!(:name => 'my test enterprise', :identifier => 'mytestenterprise', :contact_email => 'ent@noosfero.foo.bar', :contact_phone => '5555 5555')
#    a = EnterpriseHomepage.new(:name => 'article homepage')
#    e.articles << a
#    result = a.to_html
#    assert_match /ent@noosfero.foo.bar/, result
#    assert_match /5555 5555/, result
#  end

  Scenario: display profile info
    When I go to /mayhem/homepage
    Then I should see "queen@workerbees.org"
    And I should see "(288) 555-0153"

#  should 'display products list' do
#    ent = fast_create(Enterprise, :identifier => 'test_enterprise', :name => 'Test enteprise')
#    prod = ent.products.create!(:name => 'Product test', :product_category => @product_category)
#    a = EnterpriseHomepage.new(:name => 'article homepage')
#    ent.articles << a
#    result = a.to_html
#    assert_match /Product test/, result
#  end

  Scenario: display products list
    When I go to /mayhem/homepage
    Then I should see "Natural Handmade"

#  should 'not display products list if environment do not let' do
#    e = Environment.default
#    e.enable('disable_products_for_enterprises')
#    e.save!
#    ent = fast_create(Enterprise, :identifier => 'test_enterprise', :name => 'Test enteprise', :environment_id => e.id)
#    prod = ent.products.create!(:name => 'Product test', :product_category => @product_category)
#    a = EnterpriseHomepage.new(:name => 'article homepage')
#    ent.articles << a
#    result = a.to_html
#    assert_no_match /Product test/, result
#  end

# FIXME: not working
#  Scenario: not display products list if environment do not let
#    Given feature "disable_products_for_enterprises" is enabled on environment
#    When I go to /mayhem/homepage
#    Then I should not see "Natural Handmade"

#  should 'display link to product' do
#    ent = fast_create(Enterprise, :identifier => 'test_enterprise', :name => 'Test enteprise')
#    prod = ent.products.create!(:name => 'Product test', :product_category => @product_category)
#    a = EnterpriseHomepage.new(:name => 'article homepage')
#    ent.articles << a
#    result = a.to_html
#    assert_match /\/test_enterprise\/manage_products\/show\/#{prod.id}/, result
#  end

  Scenario: display link to product
    When I go to /mayhem/homepage
    And I follow "Natural Handmade"
    Then I should be taken to "Natural Handmade" product page
