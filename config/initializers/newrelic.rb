# Load newrelic agent if its config file is defined.
require 'newrelic_rpm' if File.exist?(File.dirname(__FILE__) + '/../newrelic.yml')
