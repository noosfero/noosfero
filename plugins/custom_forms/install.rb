# Make sure Noosfero's Debian Repository is included on your source.list
# Check it out: http://download.noosfero.org/debian/

# FIXME The package is not working
unless (system "gem list -i chartkick")
  system "gem install chartkick -v '~> 2.3.5'"
end
