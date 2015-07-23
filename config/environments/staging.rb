# inherit from production
require_relative 'production'

Noosfero::Application.configure do

  # expose errors
  config.consider_all_requests_local = true

  # ease debug
  config.assets.compress = false

end

