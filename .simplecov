require 'simplecov'
SimpleCov.start 'rails' do
  add_filter 'vendor'
  add_filter 'plugins'
  add_group 'Api', 'app/api'
  add_group "Models", "app/models"
  add_group "Controllers", "app/controllers"
end
SimpleCov.merge_timeout 3600

# test/unit
SimpleCov.command_name 'test:units'

# test/functionals
SimpleCov.command_name "test:functionals"

# test/integration
SimpleCov.command_name "test:integration"

# features
SimpleCov.command_name "selenium"
