require 'database_cleaner'
require 'database_cleaner/cucumber'

Cucumber::Rails::World.use_transactional_fixtures = false

Capybara.default_driver = :selenium
Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, :browser => :firefox)
end

# FIXME: 'DELETE FROM ...' is being ran 3x - see cucumber.log
DatabaseCleaner.clean_with :truncation
DatabaseCleaner.strategy = :truncation, {:pre_count => true, :reset_ids => false}

Before do
  DatabaseCleaner.start
end

Before('@ignore-hidden-elements') do
  Capybara.ignore_hidden_elements = true
end

Capybara.default_wait_time = 30
Capybara.server_host = "localhost"

After do
  DatabaseCleaner.clean
end

World(Capybara)
