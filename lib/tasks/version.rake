desc "shows noosfero version"
task :version do
  require_dependency 'noosfero'
  puts "noosfero, version #{Noosfero::VERSION}"
end
