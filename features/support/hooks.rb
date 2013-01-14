Before('@mezuro') do |scenario|
  command = "#{RAILS_ROOT}/plugins/mezuro/features/monkey-server/call_monkey_server.sh \"#{scenario.name}\""
  system command
end
