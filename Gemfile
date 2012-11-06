source :rubygems
gem 'cucumber', '0.4.0'
gem 'webrat', '0.5.1'
gem 'rspec', '1.2.9'
gem 'rspec-rails', '1.2.9'
gem 'Selenium', '>= 1.1.14'
gem 'selenium-client', '>= 1.2.17'
gem 'database_cleaner'
gem 'exception_notification', '~> 3.0.0'

#Forcing to use Debian version of this gems
#Without this, exception_notification uses 3.1.3
gem 'actionmailer',  '3.2.6'
gem 'actionpack', '3.2.6'
gem 'activemodel', '3.2.6'
gem 'activerecord', '3.2.6'
gem 'activeresource', '3.2.6'
gem 'activesupport', '3.2.6'



def program(name)
  unless system("which #{name} > /dev/null")
    puts "W: Program #{name} is needed, but was not found in your PATH"
  end
end

program 'java'
program 'firefox'
