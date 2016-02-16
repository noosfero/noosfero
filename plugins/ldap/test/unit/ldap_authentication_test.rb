require_relative '../test_helper'

class LdapAuthenticationTest < ActiveSupport::TestCase

  def pseudoEntry(data)
    entry = data.clone
    def entry.dn; 'testDN'; end
    entry
  end

  def setup
    @ldap_config = load_ldap_config
  end

  should 'host be nil as default' do
    ldap = LdapAuthentication.new
    assert_nil ldap.host
  end

  should 'create with host passed as parameter' do
    value = 'http://myhost.com'
    ldap = LdapAuthentication.new('host' => value)
    assert_equal value, ldap.host
  end

  should 'port be 389 as default' do
    ldap = LdapAuthentication.new
    assert_equal 389, ldap.port
  end

  should 'create with port passed as parameter' do
    value = 555
    ldap = LdapAuthentication.new('port' => value)
    assert_equal value, ldap.port
  end

  should 'account be nil as default' do
    ldap = LdapAuthentication.new
    assert_nil ldap.account
  end

  should 'create with account passed as parameter' do
    value = 'uid=sector,ou=Service,ou=corp,dc=company,dc=com,dc=br'
    ldap = LdapAuthentication.new('account' => value)
    assert_equal value, ldap.account
  end

  should 'account_password be nil as default' do
    ldap = LdapAuthentication.new
    assert_nil ldap.account_password
  end

  should 'create with account_password passed as parameter' do
    value = 'password'
    ldap = LdapAuthentication.new('account_password' => value)
    assert_equal value, ldap.account_password
  end

  should 'base_dn be nil as default' do
    ldap = LdapAuthentication.new
    assert_nil ldap.base_dn
  end

  should 'create with base_dn passed as parameter' do
    value = 'dc=company,dc=com,dc=br'
    ldap = LdapAuthentication.new('base_dn' => value)
    assert_equal value, ldap.base_dn
  end

  should 'attr_login be nil as default' do
    ldap = LdapAuthentication.new
    assert_nil ldap.attr_login
  end

  should 'create with attr_login passed as parameter' do
    value = 'uid'
    ldap = LdapAuthentication.new('attr_login' => value)
    assert_equal value, ldap.attr_login
  end

  should 'attr_fullname be nil as default' do
    ldap = LdapAuthentication.new
    assert_nil ldap.attr_fullname
  end

  should 'create with attr_fullname passed as parameter' do
    value = 'Noosfero System'
    ldap = LdapAuthentication.new('attr_fullname' => value)
    assert_equal value, ldap.attr_fullname
  end

  should 'attr_mail be nil as default' do
    ldap = LdapAuthentication.new
    assert_nil ldap.attr_mail
  end

  should 'create with attr_mail passed as parameter' do
    value = 'test@noosfero.com'
    ldap = LdapAuthentication.new('attr_mail' => value)
    assert_equal value, ldap.attr_mail
  end

  should 'onthefly_register be false as default' do
    ldap = LdapAuthentication.new
    refute ldap.onthefly_register
  end

  should 'create with onthefly_register passed as parameter' do
    value = true
    ldap = LdapAuthentication.new('onthefly_register' => value)
    assert_equal value, ldap.onthefly_register
  end

  should 'filter be nil as default' do
    ldap = LdapAuthentication.new
    assert_nil ldap.filter
  end

  should 'create with filter passed as parameter' do
    value = 'test'
    ldap = LdapAuthentication.new('filter' => value)
    assert_equal value, ldap.filter
  end

  should 'tls be false as default' do
    ldap = LdapAuthentication.new
    refute ldap.tls
  end

  should 'create with tls passed as parameter' do
    value = true
    ldap = LdapAuthentication.new('tls' => value)
    assert_equal value, ldap.tls
  end

  should 'onthefly_register? return true if onthefly_register is true' do
    ldap = LdapAuthentication.new('onthefly_register' => true)
    assert ldap.onthefly_register?
  end

  should 'onthefly_register? return false if onthefly_register is false' do
    ldap = LdapAuthentication.new('onthefly_register' => false)
    refute ldap.onthefly_register?
  end

  should 'detect and convert non utf-8 charset from ldap' do
    entry = pseudoEntry('name' => "Jos\xE9 Jo\xE3o")
    name = LdapAuthentication.get_attr entry, 'name'
    assert_equal name, 'José João'
  end

  should 'dont crash when entry key is empty string' do
    entry = pseudoEntry('name' => "")
    name = LdapAuthentication.get_attr entry, 'name'
    assert_equal name, ''
  end

  should 'dont crash when entry key has only a space char' do
    entry = pseudoEntry('name' => " ")
    name = LdapAuthentication.get_attr entry, 'name'
    assert_equal name, ''
  end

  should 'dont crash when entry key is nil' do
    entry = pseudoEntry('name' => nil)
    name = LdapAuthentication.get_attr entry, 'name'
    assert_equal name, nil
  end

  should 'dont crash when entry key does not exists' do
    entry = pseudoEntry({})
    name = LdapAuthentication.get_attr entry, 'name'
    assert_equal name, nil
  end

  if ldap_configured?
    should 'return the user attributes' do
      auth = LdapAuthentication.new(@ldap_config['server'])
      attributes =  auth.authenticate(@ldap_config['user']['login'],@ldap_config['user']['password'])
      assert attributes.is_a?(Hash), "An hash was not returned"
      assert_not_nil attributes[:fullname]
      assert_not_nil attributes[:mail]
    end

    should 'return nil with a invalid ldap user' do
      auth = LdapAuthentication.new(@ldap_config['server'])
      assert_equal nil, auth.authenticate('nouser','123456')
    end

    should 'return nil without a login' do
      auth = LdapAuthentication.new(@ldap_config['server'])
      assert_equal nil, auth.authenticate('', @ldap_config['user']['password'])
    end

    should 'return nil without a password' do
      auth = LdapAuthentication.new(@ldap_config['server'])
      assert_equal nil, auth.authenticate(@ldap_config['user']['login'],'')
    end

    should 'return any user without filter' do
      auth = LdapAuthentication.new(@ldap_config['server'])
      assert auth.authenticate(@ldap_config['user']['login'], @ldap_config['user']['password'])
    end

    should 'not return a valid ldap user if a filter is defined' do
      auth = LdapAuthentication.new(@ldap_config['server'])
      auth.filter = '(mail=*@test.org)'
      assert_nil auth.authenticate(@ldap_config['user']['login'], @ldap_config['user']['password'])
    end

  else
    puts LDAP_SERVER_ERROR_MESSAGE
  end


end
