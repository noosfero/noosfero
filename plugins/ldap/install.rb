begin
  gem "net-ldap", '=0.3.1'
rescue Gem::LoadError => exception
  system "gem install --user-install net-ldap -v 0.3.1"
end

puts "WARNING: This plugin is not setting up a ldap test server automatically.
Some tests may not be running. If you want to fully test this plugin, please
setup the ldap test server and make the proper configurations on
fixtures/ldap.yml.\n\n"
