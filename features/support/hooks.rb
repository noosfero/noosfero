Before do
  if !$dunit
    command = "#{RAILS_ROOT}/plugins/mezuro/script/tests/prepare_kalibro_query_file.sh"
    system command
    $dunit = true
  end
end

After ('@kalibro_restart') do
  command = "#{RAILS_ROOT}/plugins/mezuro/script/tests/delete_all_kalibro_entries.sh"
  system command
end
