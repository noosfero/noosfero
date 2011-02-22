class CreateContactLists < ActiveRecord::Migration
  def self.up
    create_table :contact_lists do |t|
      t.text :list
      t.string :error_fetching
      t.boolean :fetched, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :contact_lists
  end
end
