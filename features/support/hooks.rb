After ('@kalibro_restart') do
  command = "#{RAILS_ROOT}/plugins/mezuro/script/delete_all_kalibro_entries.sh"
  system command
end
