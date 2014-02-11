class AddExtraFieldsForPerson < ActiveRecord::Migration
  def self.up
    add_column :profiles, :personal_website, :string
    add_column :profiles, :jabber_id, :string
  end

  def self.down
    remove_column :profiles, :personal_website
    remove_column :profiles, :jabber_id
  end
end
