require_relative "../test_helper"

class ChatHelperTest < ActionView::TestCase

  include ApplicationHelper
  include ChatHelper

  should 'provide menu to change chat presence status' do
    env = Environment.default
    stubs(:environment).returns(env)
    stubs(:profile).returns(nil)
    stubs(:user).returns(create_user('testing').person)
    links = user_status_menu('fake-class', 'offline')
    assert_match /Online/, links
    assert_match /Busy/, links
    assert_match /Sign out of chat/, links
  end

  protected

  include NoosferoTestHelper

end
