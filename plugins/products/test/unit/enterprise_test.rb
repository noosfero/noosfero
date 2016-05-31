require_relative '../test_helper'

class EnterpriseTest < ActiveSupport::TestCase

  should 'provide URL to catalog area' do
    create_environment 'mycolivre.net'
    enterprise = build(Enterprise, identifier: 'testprofile', environment_id: create_environment('mycolivre.net').id)

    assert_equal({profile: enterprise.identifier, controller: 'products_plugin/catalog'}, enterprise.catalog_url)
  end

end
