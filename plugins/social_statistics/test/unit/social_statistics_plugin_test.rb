# encoding: UTF-8
require_relative "../../../../test/test_helper"

class SocialStatisticsPluginTest < ActiveSupport::TestCase

  def setup
    @plugin = SocialStatisticsPlugin.new
  end
  attr_reader :plugin

  should 'define reserved identifiers' do
    assert_includes plugin.reserved_identifiers, 'stats'
  end

  should 'not add link to user menu if user is not admin' do
    user = mock()
    user.stubs(:is_admin?).returns(false)

    assert_nil plugin.user_menu_items(user)
  end

  should 'add link to user menu if user is admin' do
    user = mock()
    user.stubs(:is_admin?).returns(true)

    assert plugin.user_menu_items(user).present?
  end
end
