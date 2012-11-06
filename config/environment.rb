# Load the rails application
require File.expand_path('../application', __FILE__)

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
#ENV['RAILS_ENV'] ||= 'production'

# extra directories for controllers organization 
extra_controller_dirs = %w[
  app/controllers/my_profile
  app/controllers/admin
  app/controllers/system
  app/controllers/public
].map {|item| File.join(Rails.root, item) }

def noosfero_session_secret
  require 'fileutils'
  target_dir = File.join(File.dirname(__FILE__), '/../tmp')
  FileUtils.mkdir_p(target_dir)
  file = File.join(target_dir, 'session.secret')
  if !File.exists?(file)
    secret = (1..128).map { %w[0 1 2 3 4 5 6 7 8 9 a b c d e f][rand(16)] }.join('')
    File.open(file, 'w') do |f|
      f.puts secret
    end
  end
  File.read(file).strip
end

#FIXME controller_paths are no more supported on Rails 3
#extra_controller_dirs.each do |item|
#  $LOAD_PATH << item
#  config.controller_paths << item
#end
#extra_controller_dirs.each do |item|
#  (ActiveSupport.const_defined?('Dependencies') ? ActiveSupport::Dependencies : ::Dependencies).load_paths << item
#end

# Add new inflection rules using the following format 
# (all these examples are active by default):
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# Include your application configuration below

ActiveRecord::Base.store_full_sti_class = true

#FIXME: Probably act_as_taggable_on is not being loaded or this should be on another place
#Tag.hierarchical = true

# several local libraries
require 'noosfero'
require 'sqlite_extension'

# load a local configuration if present, but not under test environment.
if !['test', 'cucumber'].include?(ENV['RAILS_ENV'])
  localconfigfile = File.join(Rails.root, 'config', 'local.rb')
  if File.exists?(localconfigfile)
    require localconfigfile
  end
end

Rails3::Application.initialize!