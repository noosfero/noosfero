class AddActivatedAtToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :activation_code, :string, :limit => 40
    add_column :users, :activated_at, :datetime
    if ApplicationRecord.connection.adapter_name == 'SQLite'
      execute "update users set activated_at = datetime();"
    else
      execute "update users set activated_at = now();"
    end
  end

  def self.down
    remove_column :users, :activation_code
    remove_column :users, :activated_at
  end
end
