# our defaults
listen "0.0.0.0:3000"
pid 'tmp/pids/unicorn.pid'

preload_app true
GC.respond_to?(:copy_on_write_friendly=) and
  GC.copy_on_write_friendly = true

before_fork do |server, worker|
  ActiveRecord::Base.connection.disconnect! if defined?(ActiveRecord::Base)
end

after_fork do |server, worker|
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord::Base)
end

# load local configuration file, if it exists
config = File.join(File.dirname(__FILE__), '../../config/unicorn.rb')
instance_eval(File.read(config), config) if File.exists?(config)

