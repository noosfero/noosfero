require File.dirname(__FILE__) + '/../../config/environment'
require 'noosfero'
require 'gettext/rails'
include GetText

namespace :db do
  desc "Populate database with basic required data to run application"
  task :populate do
    Environment.create!(:name => 'Noosfero', :is_default => true) unless (Environment.default)
  end
end

# vim: ft=ruby
