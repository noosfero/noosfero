class AddBscToEnterprise < ActiveRecord::Migration
  def self.up
    add_column :profiles, :bsc_id, :integer
  end

  def self.down
    remove_column :profiles, :bsc_id
  end
end
