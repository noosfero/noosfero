require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  VALID_CNPJ = '94.132.024/0001-48'

  should 'return have bsc' do
    bsc = BscPlugin::Bsc.create!({:business_name => 'Sample Bsc', :identifier => 'sample-bsc', :company_name => 'Sample Bsc Ltda.', :cnpj => VALID_CNPJ})
    enterprise = fast_create(Enterprise, :bsc_id => bsc.id)
    product = fast_create(Product, :profile_id => enterprise.id)

    assert_equal bsc, product.bsc
  end

  should 'have contracts through sales' do
    product = fast_create(Product)
    contract1 = BscPlugin::Contract.create!(:bsc => BscPlugin::Bsc.new, :client_name => 'Marvin')
    contract2 = BscPlugin::Contract.create!(:bsc => BscPlugin::Bsc.new, :client_name => 'Marvin')
    sale1 = BscPlugin::Sale.create!(:product => product, :contract => contract1, :quantity => 3)
    sale2 = BscPlugin::Sale.create!(:product => product, :contract => contract2, :quantity => 5)

    assert_includes product.contracts, contract1
    assert_includes product.contracts, contract2
  end
end
