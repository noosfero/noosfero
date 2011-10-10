require File.dirname(__FILE__) + '/../../../../../test/test_helper'
require File.dirname(__FILE__) + '/../../../../../app/models/uploaded_file'
require File.dirname(__FILE__) + '/../../../../../app/models/enterprise'
require File.dirname(__FILE__) + '/../../../lib/ext/enterprise'

class ProductTest < Test::Unit::TestCase
  VALID_CNPJ = '94.132.024/0001-48'

  should 'belongs to a bsc' do
    bsc = BscPlugin::Bsc.create!({:business_name => 'Sample Bsc', :identifier => 'sample-bsc', :company_name => 'Sample Bsc Ltda.', :cnpj => VALID_CNPJ})
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
end

