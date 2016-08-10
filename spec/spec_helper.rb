require_relative '../config/environment'
require 'rspec/rails'

require_relative 'support/factories'

require 'database_cleaner'

RSpec.configure do |config|

  config.fixture_path = 'spec/fixtures'

  config.include Noosfero::Factory

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with :truncation
  end
  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

end

