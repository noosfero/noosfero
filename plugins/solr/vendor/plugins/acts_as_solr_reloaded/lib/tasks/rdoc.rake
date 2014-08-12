require 'rake/testtask'
require 'rdoc/task'

Rake::RDocTask.new do |rd|
  rd.main = "README.rdoc"
  rd.rdoc_dir = "rdoc"
  rd.rdoc_files.exclude("lib/solr/**/*.rb", "lib/solr.rb")
  rd.rdoc_files.include("README.rdoc", "lib/**/*.rb")
end

