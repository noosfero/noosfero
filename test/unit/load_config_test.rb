require File.dirname(__FILE__) + '/../test_helper'

class LoadConfigTest < ActiveSupport::TestCase

  should 'ensure NOOSFERO_CONF was defined' do
    assert NOOSFERO_CONF
    assert_kind_of Hash, NOOSFERO_CONF
  end

end
