class AddHstoreFields < ActiveRecord::Migration
  def change
    enable_extension :hstore

    add_column :profiles, :metadata, :hstore, :default => {}
    add_column :articles, :metadata, :hstore, :default => {}
    add_column :tasks, :metadata, :hstore, :default => {}
    add_column :blocks, :metadata, :hstore, :default => {}
    add_column :users, :metadata, :hstore, :default => {}

    add_index :profiles, :metadata, using: :gist
    add_index :articles, :metadata, using: :gist
    add_index :tasks, :metadata, using: :gist
    add_index :blocks, :metadata, using: :gist
    add_index :users, :metadata, using: :gist
  end
end
