class AddUspIdToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :usp_id, :string
  end

  def self.down
    remove_column :profiles, :usp_id
  end
end
