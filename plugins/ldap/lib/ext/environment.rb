require_dependency 'environment'

class Environment

  settings_items :ldap_plugin, :type => :hash, :default => {}

  validates_presence_of :ldap_plugin_host, :if => lambda {|env| !env.ldap_plugin.blank? }

  attr_accessible :ldap_plugin_host, :ldap_plugin_port, :ldap_plugin_tls, :ldap_plugin_onthefly_register, :ldap_plugin_account, :ldap_plugin_account_password, :ldap_plugin_filter, :ldap_plugin_base_dn, :ldap_plugin_attr_mail, :ldap_plugin_attr_login, :ldap_plugin_attr_fullname, :ldap_plugin_allow_password_recovery

  def ldap_plugin_attributes
    self.ldap_plugin || {}
  end

  def ldap_plugin_host= host
    self.ldap_plugin = {} if self.ldap_plugin.blank?
    self.ldap_plugin['host'] = host
  end

  def ldap_plugin_host
    self.ldap_plugin['host']
  end

  def ldap_plugin_port= port
    self.ldap_plugin = {} if self.ldap_plugin.blank?
    self.ldap_plugin['port'] = port
  end

  def ldap_plugin_port
    self.ldap_plugin = {} if self.ldap_plugin.blank?
    self.ldap_plugin['port'] ||= 389
    self.ldap_plugin['port']
  end

  def ldap_plugin_account
    self.ldap_plugin['account']
  end

  def ldap_plugin_account= account
    self.ldap_plugin = {} if self.ldap_plugin.blank?
    self.ldap_plugin['account'] = account
  end

  def ldap_plugin_account_password
    self.ldap_plugin['account_password']
  end

  def ldap_plugin_account_password= password
    self.ldap_plugin = {} if self.ldap_plugin.blank?
    self.ldap_plugin['account_password'] = password
  end

  def ldap_plugin_base_dn
    self.ldap_plugin['base_dn']
  end

  def ldap_plugin_base_dn= base_dn
    self.ldap_plugin = {} if self.ldap_plugin.blank?
    self.ldap_plugin['base_dn'] =  base_dn
  end

  def ldap_plugin_attr_login
    self.ldap_plugin['attr_login']
  end

  def ldap_plugin_attr_login= login
    self.ldap_plugin = {} if self.ldap_plugin.blank?
    self.ldap_plugin['attr_login'] = login
  end

  def ldap_plugin_attr_fullname
    self.ldap_plugin['attr_fullname']
  end

  def ldap_plugin_attr_fullname= fullname
    self.ldap_plugin = {} if self.ldap_plugin.blank?
    self.ldap_plugin['attr_fullname'] = fullname
  end

  def ldap_plugin_attr_mail
    self.ldap_plugin['attr_mail']
  end

  def ldap_plugin_attr_mail= mail
    self.ldap_plugin = {} if self.ldap_plugin.blank?
    self.ldap_plugin['attr_mail'] =  mail
  end

  def ldap_plugin_onthefly_register
    self.ldap_plugin['onthefly_register'].to_s == 'true'
  end

  def ldap_plugin_onthefly_register= value
    self.ldap_plugin = {} if self.ldap_plugin.blank?
    self.ldap_plugin['onthefly_register'] = (value.to_s == '1') ? true : false
  end

  def ldap_plugin_filter
    self.ldap_plugin['filter']
  end

  def ldap_plugin_filter= filter
    self.ldap_plugin = {} if self.ldap_plugin.blank?
    self.ldap_plugin['filter'] = filter
  end

  def ldap_plugin_tls
    self.ldap_plugin['tls'] ||= false
  end

  def ldap_plugin_tls= value
    self.ldap_plugin = {} if self.ldap_plugin.blank?
    self.ldap_plugin['tls'] = (value.to_s == '1') ? true : false
  end

  def ldap_plugin_allow_password_recovery
    self.ldap_plugin['allow_password_recovery'] ||= false
  end

  def ldap_plugin_allow_password_recovery= value
    self.ldap_plugin = {} if self.ldap_plugin.blank?
    self.ldap_plugin['allow_password_recovery'] = (value.to_i == 1)
  end

end
