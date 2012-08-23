require File.dirname(__FILE__) + '/../test_helper'

class BoxTest < ActiveSupport::TestCase
  should 'retrieve environment based on owner' do
    profile = fast_create(Profile)
    box = fast_create(Box, :owner_id => profile.id, :owner_type => 'Profile')
    assert_equal profile.environment, box.environment

    box = fast_create(Box, :owner_id => Environment.default.id, :owner_type => 'Environment')
    assert_equal Environment.default, box.environment
  end
end
