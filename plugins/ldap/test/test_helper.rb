require 'test_helper'

def load_ldap_config
  begin
    YAML.load_file(File.dirname(__FILE__) + '/../fixtures/ldap.yml')
  rescue Errno::ENOENT => e
    # There is no config file
    return nil
  end
end

def ldap_configured?
  ldap_config = load_ldap_config
  begin
    test_ldap = Net::LDAP.new(:host => ldap_config['server']['host'], :port => ldap_config['server']['port'])
    return test_ldap.bind
  rescue Exception => e
    #LDAP is not listening
    return nil
  end
end

LDAP_SERVER_ERROR_MESSAGE = "\nWARNING: LDAP test server is not configured properly. Please see the file fixtures/ldap.yml on ldap plugin\n\n"
