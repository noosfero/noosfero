db_path = 'plugins/stoa/test/test.db'
ActiveRecord::Base.configurations['stoa'] = {
  adapter:  'sqlite3',
  database: db_path,
}

ActiveRecord::Base.establish_connection :stoa

ActiveRecord::Schema.verbose = false
ActiveRecord::Schema.create_table 'pessoa' do |t|
  t.integer  'codpes'
  t.text     'numcpf'
  t.date     'dtanas'
end unless 'pessoa'.in? ActiveRecord::Base.connection.tables

ActiveRecord::Base.establish_connection :test

at_exit do
  File.unlink db_path
end
