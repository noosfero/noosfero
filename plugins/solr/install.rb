#raise "Not ready yet. Some tests are failing."
require 'rake'

tasks_dir = File.join(File.dirname(__FILE__), 'vendor', 'plugins', 'acts_as_solr_reloaded', 'lib', 'tasks', '*.rake')

Dir[tasks_dir].each do |file|
  load file
end

puts 'To download solr:'
puts '$ cd plugins/solr'
puts '$ rake solr:download'
