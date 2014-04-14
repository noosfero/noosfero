class AddIndexesForProfileSearch < ActiveRecord::Migration
  def self.up
    add_index :profiles, :created_at
  end

  def self.down
    remove_index :profiles, :created_at
  end
end
