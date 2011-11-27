ActiveRecord::Base.establish_connection(
  :adapter  => "sqlite3",
  :database => "db_test.db"
)

load File.dirname(__FILE__) + "/fixtures/schema.rb"
