require 'simplecov'
SimpleCov.start 'rails' do
  add_filter 'vendor'
  add_group 'Api', 'app/api'
  add_group 'Plugins', 'plugins'
  add_group "Models", "app/models"
  add_group "Controllers", "app/controllers"
end
