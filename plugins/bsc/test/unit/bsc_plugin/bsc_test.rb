require File.dirname(__FILE__) + '/../../../../../test/test_helper'
require File.dirname(__FILE__) + '/../../../../../app/models/uploaded_file'
require File.dirname(__FILE__) + '/../../../lib/ext/enterprise'

class BscPlugin::BscTest < Test::Unit::TestCase
  VALID_CNPJ = '94.132.024/0001-48'

  should 'validate presence of cnpj' do
    bsc = BscPlugin::Bsc.new()
    bsc.valid?

    assert bsc.errors.invalid?(:cnpj)
  end

  should 'validate uniqueness of cnpj' do
    bsc1 = BscPlugin::Bsc.create!({:business_name => 'Sample Bsc', :identifier => 'sample-bsc', :company_name => 'Sample Bsc Ltda.', :cnpj => VALID_CNPJ})
    bsc2 = BscPlugin::Bsc.new(:cnpj => VALID_CNPJ)
    bsc2.valid?
   assert bsc2.errors.invalid?(:cnpj)
  end

  should 'have many enterprises' do
    e1 = Enterprise.new(:name => 'Enterprise1', :identifier => 'enterprise1')
    e2 = Enterprise.new(:name => 'Enterprise2', :identifier => 'enterprise2')
    bsc = BscPlugin::Bsc.new(:business_name => 'Sample Bsc', :company_name => 'Sample Bsc Ltda.', :identifier => 'sample-bsc', :cnpj => VALID_CNPJ)
    bsc.enterprises << e1
    bsc.enterprises << e2
    bsc.save!

    assert_equal e1.bsc, bsc
    assert_equal e2.bsc, bsc
  end

  should 'verify already requested enterprises' do
    e1 = fast_create(Enterprise)
    e2 = fast_create(Enterprise)
    bsc = BscPlugin::Bsc.new()
    task = BscPlugin::AssociateEnterprise.new(:target => e1, :bsc => bsc)
    bsc.enterprise_requests.stubs(:pending).returns([task])

    assert bsc.already_requested?(e1)
    assert !bsc.already_requested?(e2)
  end

  should 'return associated enterprises products' do
    e1 = fast_create(Enterprise)
    e2 = fast_create(Enterprise)
    category = fast_create(ProductCategory)
    bsc = BscPlugin::Bsc.new()

    p1 = fast_create(Product, :product_category_id => category.id)
    p2 = fast_create(Product, :product_category_id => category.id)
    p3 = fast_create(Product, :product_category_id => category.id)

    e1.products << p1
    e1.products << p2
    e2.products << p3

    bsc.enterprises << e1
    bsc.enterprises << e2

    assert_includes bsc.products, p1
    assert_includes bsc.products, p2
    assert_includes bsc.products, p3
  end

  should 'reload products' do
    e = fast_create(Enterprise)
    category = fast_create(ProductCategory)
    bsc = BscPlugin::Bsc.create!(:business_name => 'Sample Bsc', :company_name => 'Sample Bsc', :identifier => 'sample-bsc', :cnpj => VALID_CNPJ)
    p = fast_create(Product, :product_category_id => category.id)

    e.bsc = bsc
    e.save!
    e.products << p

    assert_equal [], bsc.products
    assert_equal [p], bsc.products(true)
  end

  should 'not be able to create product' do
    bsc = BscPlugin::Bsc.new
    assert !bsc.create_product?
  end

end
