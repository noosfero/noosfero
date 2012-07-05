require 'savon'
require 'yaml'

Savon.configure do |config|
  config.log = HTTPI.log = (RAILS_ENV == 'development')
end
