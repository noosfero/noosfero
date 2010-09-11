require File.dirname(__FILE__) + '/../test_helper'

class ChatHelperTest < Test::Unit::TestCase

  include ChatHelper

  should 'provide menu to change chat presence status' do
    env = Environment.default
    stubs(:environment).returns(env)
    stubs(:current_user).returns(create_user('testing'))
    links = user_status_menu('fake-class', 'offline')
    assert_match /Online/, links
    assert_match /Busy/, links
    assert_match /Sign out of chat/, links
  end

  protected

  include NoosferoTestHelper

end
