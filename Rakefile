#!/usr/bin/env rake

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Noosfero::Application.load_tasks

[
  "baseplugins/*/{tasks,lib/tasks,rails/tasks}/**/*.rake",
  "config/plugins/*/{tasks,lib/tasks,rails/tasks}/**/*.rake",
  "config/plugins/*/vendor/plugins/*/{tasks,lib/tasks,rails/tasks}/**/*.rake",
].map do |pattern|
  Dir.glob(pattern).sort
end.flatten.each do |taskfile|
  load taskfile
end

desc "Print out grape routes"
task :grape_routes => :environment do
  #require 'api/api.rb'
  Noosfero::API::API.routes.each do |route|
    puts route
    method = route.route_method
    path = route.route_path
    puts "     #{method} #{path}"
  end
end

