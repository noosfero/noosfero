class MoveFromHstoreToJsonb < ActiveRecord::Migration
  def up
    %w[profiles articles tasks blocks users].each do |table|
      connection.execute "ALTER TABLE #{table} ALTER COLUMN metadata SET DEFAULT null"
      connection.execute "DROP INDEX index_#{table}_on_metadata"

      connection.execute "ALTER TABLE #{table} ALTER COLUMN metadata TYPE JSONB USING CAST(metadata as JSONB)"
      connection.execute "ALTER TABLE #{table} ALTER COLUMN metadata SET DEFAULT '{}'"
      add_index table, :metadata, using: :gin
    end
  end
end
