# Load the rails application
require File.expand_path('../application', __FILE__)

#FIXME Necessary hack to avoid the need of downgrading rubygems on rails 2.3.5
# http://stackoverflow.com/questions/5564251/uninitialized-constant-activesupportdependenciesmutex
require 'thread'

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
#ENV['RAILS_ENV'] ||= 'production'

# extra directories for controllers organization 
extra_controller_dirs = %w[
].map {|item| Rails.root.join(item) }

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
require_dependency 'noosfero'
#FIXME: error when call lib/sqlite_extention
#require 'sqlite_extension'

# load a local configuration if present, but not under test environment.
if !['test', 'cucumber'].include?(ENV['RAILS_ENV'])
  localconfigfile = Rails.root.join('config', 'local.rb')
  if File.exists?(localconfigfile)
    require localconfigfile
  end
end

Noosfero::Application.initialize!
