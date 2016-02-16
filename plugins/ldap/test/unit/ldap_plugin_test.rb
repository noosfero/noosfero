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

  should 'return login when exists a login attribute returned by ldap' do
    plugin = LdapPlugin.new
    assert_equal 'test', plugin.get_login({:uid => 'test'}, 'uid', 'test2')
  end

  should 'return the attribute configured by attr_login when the attribute exists' do
    plugin = LdapPlugin.new
    assert_equal 'test', plugin.get_login({:uid => 'test'}, 'uid', 'test2')
  end

  should 'return login when the ldap attribute does not exists' do
    plugin = LdapPlugin.new
    assert_equal 'test2', plugin.get_login({:uid => 'test'}, 'mail', 'test2')
  end

  should 'use the first word at attr_login as the login key' do
    plugin = LdapPlugin.new
    assert_equal 'test', plugin.get_login({:uid => 'test', :mail => 'test@test'}, 'uid mail', 'test2')
  end

end
