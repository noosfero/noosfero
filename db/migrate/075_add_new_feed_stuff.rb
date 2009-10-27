class AddNewFeedStuff < ActiveRecord::Migration

  def self.up
    add_column :blocks, :enabled, :boolean, :default => true
    execute('update blocks set enabled = (1=1)')

    add_column :blocks, :created_at, :datetime
    add_column :blocks, :updated_at, :datetime
    add_column :blocks, :fetched_at, :datetime
    execute("update blocks set created_at = '2009-10-23 17:00', updated_at = '2009-10-23 17:00'")

    add_index :blocks, :enabled
    add_index :blocks, :fetched_at
    add_index :blocks, :type

    add_column :external_feeds, :error_message, :text
    add_column :external_feeds, :update_errors, :integer, :default => 0
    execute('update external_feeds set update_errors = 0')

    add_index :external_feeds, :enabled
    add_index :external_feeds, :fetched_at
  end

  def self.down
    remove_index :blocks, :enabled
    remove_index :blocks, :fetched_at
    remove_index :blocks, :type
    remove_column :blocks, :enabled
    remove_column :blocks, :updated_at
    remove_column :blocks, :created_at
    remove_column :blocks, :fetched_at

    remove_index :external_feeds, :enabled
    remove_index :external_feeds, :fetched_at
    remove_column :external_feeds, :error_message
    remove_column :external_feeds, :update_errors
  end

end

