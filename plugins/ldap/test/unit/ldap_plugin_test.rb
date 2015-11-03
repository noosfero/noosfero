require 'test_helper'

class LdapPluginTest < ActiveSupport::TestCase

  should "not allow user registration" do
    plugin = LdapPlugin.new
    refute plugin.allow_user_registration
  end

  should "not allow password recovery" do
    plugin = LdapPlugin.new
    plugin.context = mock
    plugin.context.expects(:environment).returns(Environment.default)
    refute plugin.allow_password_recovery
  end

end
