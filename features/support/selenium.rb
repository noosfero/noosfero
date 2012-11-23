require 'rbconfig'
require 'cucumber/formatter/unicode'

require 'capybara'
require 'capybara/dsl'
require "capybara/cucumber"

require 'database_cleaner'
require 'database_cleaner/cucumber'

Cucumber::Rails::World.use_transactional_fixtures = false

Capybara.default_driver = :selenium
Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, :browser => :firefox)
end

DatabaseCleaner.clean_with :truncation
DatabaseCleaner.strategy = :truncation

Before do
  Fixtures.reset_cache
  fixtures_folder = File.join(RAILS_ROOT, 'test', 'fixtures')
  fixtures = ['environments', 'roles']
  Fixtures.create_fixtures(fixtures_folder, fixtures)
  ENV['LANG'] = 'C'
  DatabaseCleaner.start
end

After do
  sleep 2
  DatabaseCleaner.clean
end

World(Capybara)
