# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

ENV['RAILS_ENV'] ||= 'development'

# This is for plugins that wants to use seeds.rb
# Check for example on the Foo plugin
plugin_seed_dirs = Dir.glob(Rails.root.join('{baseplugins,config/plugins}', '*', 'db', 'seeds.rb'))
plugin_seed_dirs.each { |path| load path }
