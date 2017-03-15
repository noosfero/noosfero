ActiveRecord::Base.configurations['stoa'] = {
  adapter:  'sqlite3',
  database: Tempfile.new('stoa-test').path,
}

ActiveRecord::Base.establish_connection :stoa
ActiveRecord::Schema.verbose = false
ActiveRecord::Schema.create_table 'pessoa' do |t|
  t.integer  'codpes'
  t.text     'numcpf'
  t.date     'dtanas'
end
ActiveRecord::Base.establish_connection :test

