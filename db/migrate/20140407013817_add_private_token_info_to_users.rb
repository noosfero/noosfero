class AddPrivateTokenInfoToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :private_token, :string
    add_column :users, :private_token_generated_at, :datetime
  end

  def self.down
    remove_column :users, :private_token
    remove_column :users, :private_token_generated_at
  end
end
