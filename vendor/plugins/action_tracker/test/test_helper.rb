ENV['Rails.root'] ||= File.dirname(__FILE__) + '/../../../..'
require File.expand_path(File.join(ENV['Rails.root'], 'config/environment.rb'))

ENV["RAILS_ENV"] = "test"
require 'test_help'
