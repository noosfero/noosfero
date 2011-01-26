require File.dirname(__FILE__) + '/../test_helper'

class LoadConfigTest < Test::Unit::TestCase

  should 'ensure YAML file exists' do
    assert File.exists?("#{RAILS_ROOT}/config/noosfero.yml")
  end

  should 'ensure YAML file was loaded' do
    assert NOOSFERO_CONF
    assert_kind_of Hash, NOOSFERO_CONF
  end

end
