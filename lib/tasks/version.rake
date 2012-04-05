desc "shows noosfero version"
task :version do
  require 'noosfero'
  puts "noosfero, version #{Noosfero::VERSION}"
end
