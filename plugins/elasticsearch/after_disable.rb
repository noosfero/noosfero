require 'rake'

tasks_dir = File.join(File.dirname(__FILE__), 'Rakefile')

Dir[tasks_dir].each do |file|
  load file
end

Rake.application['stop'].invoke
