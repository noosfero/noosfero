require_relative 'dotenv'
require_relative 'application'

Noosfero::Application.initialize!

# load a local configuration if present, but not under test environment.
unless ENV['RAILS_ENV'].in? %w[test cucumber]
  localconfigfile = Rails.root.join('config', 'local.rb')
  require localconfigfile if File.exists? localconfigfile
end

