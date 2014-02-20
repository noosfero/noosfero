require "#{File.dirname(__FILE__)}/../test_helper"

class EnterpriseTest < ActiveSupport::TestCase
  def setup
    @environment = Environment.default
    @environment.enable_plugin(SolrPlugin)
    @product_category = fast_create(ProductCategory)
  end

  attr_accessor :environment, :product_category

  should 'reindex when products are changed' do
    enterprise = fast_create(Enterprise)
    product = fast_create(Product, :profile_id => enterprise.id, :product_category_id => product_category.id)
    Product.expects(:solr_batch_add_association).with(product, :enterprise)
    product.update_attribute :name, "novo nome"
  end

  should 'be found in search for its product categories' do
    TestSolr.enable
    ent1 = fast_create(Enterprise, :name => 'test1', :identifier => 'test1')
    prod_cat = fast_create(ProductCategory, :name => 'pctest', :environment_id => Environment.default.id)
    prod = ent1.products.create!(:name => 'teste', :product_category => prod_cat)

    ent2 = fast_create(Enterprise, :name => 'test2', :identifier => 'test2')

    result = Enterprise.find_by_contents(prod_cat.name)[:results]

    assert_includes result, ent1
    assert_not_includes result, ent2
  end

  should 'be found in search for its product categories hierarchy' do
    TestSolr.enable
    ent1 = fast_create(Enterprise, :name => 'test1', :identifier => 'test1')
    prod_cat = fast_create(ProductCategory, :name => 'pctest', :environment_id => Environment.default.id)
    prod_child = fast_create(ProductCategory, :name => 'pchild', :environment_id => Environment.default.id, :parent_id => prod_cat.id)
    prod = ent1.products.create!(:name => 'teste', :product_category => prod_child)

    ent2 = fast_create(Enterprise, :name => 'test2', :identifier => 'test2')

    result = Enterprise.find_by_contents(prod_cat.name)[:results]

    assert_includes result, ent1
    assert_not_includes result, ent2
  end
end
