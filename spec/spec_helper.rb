require_relative '../config/environment'
require 'rspec/rails'

require_relative 'support/factories'
require_relative 'concerns/metadata_scopes_spec'

require 'database_cleaner'

RSpec.configure do |config|

  config.fixture_path = 'spec/fixtures'
  config.include Noosfero::Factory

# This cleaning method is important when you have annomalous data created on
# the database but it consumes a lot of time.
#
#   config.before(:suite) do
#    DatabaseCleaner.clean_with(:truncation)
#  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, :js => true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
