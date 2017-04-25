# borrowed from err who borrowed from topfunky who borrowed from...

# set up test environment
RAILS_ENV = 'test'
require_relative '../../../../config/environment.rb'

# load test schema
load(File.dirname(__FILE__) + "/schema.rb")

# load test models
require_relative 'models/person'
require_relative 'models/entry'
require_relative 'models/comment'
require_relative 'models/message'
require_relative 'models/review'
