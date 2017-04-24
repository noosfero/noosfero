if ENV["COVERAGE"]
  SimpleCov.start 'rails' do
    add_filter 'vendor'
    add_filter 'plugins'
    add_group 'Api', 'app/api'
    add_group "Models", "app/models"
    add_group "Controllers", "app/controllers"
  end 
end 
