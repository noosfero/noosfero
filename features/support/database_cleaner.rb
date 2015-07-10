require 'database_cleaner'
require 'database_cleaner/cucumber'

Cucumber::Rails::World.use_transactional_fixtures = false
# FIXME: 'DELETE FROM ...' is being ran 3x - see cucumber.log
DatabaseCleaner.clean_with :truncation
DatabaseCleaner.strategy = :truncation, {:pre_count => true, :reset_ids => false}

Before do
  DatabaseCleaner.start
end

After do
  DatabaseCleaner.clean
end

