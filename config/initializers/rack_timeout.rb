begin
  require 'rack-timeout'
  Rack::Timeout.service_timeout = 20
rescue LoadError
  # put 'rack-timeout' on config/Gemfile to use
end
