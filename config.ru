# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'

use Rack::Cors do
  allow do
    origins '*'
    resource '/api/*', :headers => :any, :methods => [:get, :post]
  end
end

rails_app = Rack::Builder.new do
  if ENV['RAILS_RELATIVE_URL_ROOT']
    map ENV['RAILS_RELATIVE_URL_ROOT'] do
      run Noosfero::Application
    end
  else
    run Noosfero::Application
  end
end

run Rack::Cascade.new([
  rails_app,
  Api::App
])
