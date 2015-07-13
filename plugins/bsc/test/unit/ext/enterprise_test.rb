require 'test_helper'

class EnterpriseTest < ActiveSupport::TestCase
  VALID_CNPJ = '94.132.024/0001-48'

  def setup
    @bsc = BscPlugin::Bsc.create!({:business_name => 'Sample Bsc', :identifier => 'sample-bsc', :company_name => 'Sample Bsc Ltda.', :cnpj => VALID_CNPJ})
  end

  attr_accessor :bsc

  should 'belongs to a bsc' do
    enterprise = fast_create(Enterprise, :bsc_id => bsc.id)
    assert_equal bsc, enterprise.bsc
  end

  should 'return correct enterprises on validated and not validated namedscopes' do
    validated_enterprise = fast_create(Enterprise, :validated => true)
    not_validated_enterprise = fast_create(Enterprise, :validated => false)

    assert_includes Enterprise.validated, validated_enterprise
    assert_not_includes Enterprise.validated, not_validated_enterprise
    assert_not_includes Enterprise.not_validated, validated_enterprise
    assert_includes Enterprise.not_validated, not_validated_enterprise
  end

  should 'be involved with many contracts' do
    enterprise = fast_create(Enterprise)
    contract1 = BscPlugin::Contract.create!(:bsc => bsc, :client_name => 'Marvin')
    contract2 = BscPlugin::Contract.create!(:bsc => bsc, :client_name => 'Marvin')
    enterprise.contracts << contract1
    enterprise.contracts << contract2

    assert_includes enterprise.contracts, contract1
    assert_includes enterprise.contracts, contract2
  end
end

