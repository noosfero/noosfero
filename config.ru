# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

#use Rails::Rack::LogTailer
#use Rails::Rack::Static
#run ActionController::Dispatcher.new

rails_app = Rack::Builder.new do
  run Noosfero::Application
end

run Rack::Cascade.new([
  Noosfero::API::API,
  rails_app
])
