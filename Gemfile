source :rubygems

gem 'exception_notification', '1.0.20090728'
gem 'system_timer'

group :test do
  gem 'rspec', '1.2.9'
  gem 'rspec-rails', '1.2.9'
end

group :cucumber do
  gem 'rake', '0.8.7'
  gem 'cucumber-rails', '0.3.2'
  gem 'capybara', '1.1.1'
  gem 'cucumber', '1.1.0'
  gem 'database_cleaner'
end

def program(name)
  unless system("which #{name} > /dev/null")
    puts "W: Program #{name} is needed, but was not found in your PATH"
  end
end

program 'java'
program 'firefox'
