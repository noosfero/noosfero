ENV["RAILS_ENV"] ||= "cucumber"
require "simplecov"

require "cucumber/rails"

Capybara.ignore_hidden_elements = true

# Capybara defaults to CSS3 selectors rather than XPath.
# If you'd prefer to use XPath, just uncomment this line and adjust any
# selectors in your step definitions to use the XPath syntax.
# Capybara.default_selector = :xpath

# By default, any exception happening in your Rails application will bubble up
# to Cucumber so that your scenario will fail. This is a different from how
# your application behaves in the production environment, where an error page will
# be rendered instead.
#
# Sometimes we want to override this default behaviour and allow Rails to rescue
# exceptions and display an error page (just like when the app is running in production).
# Typical scenarios where you want to do this is when you test your error pages.
# There are two ways to allow Rails to rescue exceptions:
#
# 1) Tag your scenario (or feature) with @allow-rescue
#
# 2) Set the value below to true. Beware that doing this globally is not
# recommended as it will mask a lot of errors for you!
#
ActionController::Base.allow_rescue = false

# Remove/comment out the lines below if your app doesn't have a database.
# For some databases (like MongoDB and CouchDB) you may need to use :truncation instead.
begin
  DatabaseCleaner.strategy = :transaction
rescue NameError
  raise "You need to add database_cleaner to your Gemfile (in the :test group) if you wish to use it."
end

# You may also want to configure DatabaseCleaner to use different strategies for certain features and scenarios.
# See the DatabaseCleaner documentation for details. Example:
#
#   Before('@no-txn,@selenium,@culerity,@celerity,@javascript') do
#     # { :except => [:widgets] } may not do what you expect here
#     # as Cucumber::Rails::Database.javascript_strategy overrides
#     # this setting.
#     DatabaseCleaner.strategy = :truncation
#   end
#
#   Before('~@no-txn', '~@selenium', '~@culerity', '~@celerity', '~@javascript') do
#     DatabaseCleaner.strategy = :transaction
#   end
#

Capybara.server = :webrick
Cucumber::Rails::World.use_transactional_tests = true
# How to clean your database when transactions are turned off. See
# http://github.com/bmabey/database_cleaner for more info.

Before do
  fixture_set = ActiveRecord::FixtureSet
  fixture_set.reset_cache
  fixtures_folder = Rails.root.join("test", "fixtures")
  fixtures = ["environments", "roles"]
  fixture_set.create_fixtures(fixtures_folder, fixtures)

  # The same browser session is used across tests, so expire caching
  # can create changes from scenario to another.
  e = Environment.default
  e.home_cache_in_minutes    = 0
  e.general_cache_in_minutes = 0
  e.profile_cache_in_minutes = 0
  e.save
end
