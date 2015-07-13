require 'test_helper'

class LdapPluginTest < ActiveSupport::TestCase

  should "not allow user registration" do
    plugin = LdapPlugin.new
    assert !plugin.allow_user_registration
  end

  should "not allow password recovery" do
    plugin = LdapPlugin.new
    assert !plugin.allow_password_recovery
  end

end
