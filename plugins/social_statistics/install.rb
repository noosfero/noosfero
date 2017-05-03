# Make sure Noosfero's Debian Repository is included on your source.list
# Check it out: http://download.noosfero.org/debian/

#FIXME The package is not working
#unless system 'dpkg -s ruby-blazer'
  #system 'sudo apt-get update'
  #unless system 'sudo apt-get install -y ruby-blazer'
    #exit $?.exitstatus
  #end
#end

system 'gem install blazer'
