require 'test_helper'

class CreateEnterpriseTest < ActiveSupport::TestCase

  should 'inlude the parent field in create enterprise' do
    create_enterprise = CreateEnterprise.new
    assert_nothing_raised { create_enterprise.sub_organizations_plugin_parent_to_be = '999' }
  end

end

