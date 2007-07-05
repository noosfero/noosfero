class CreateProfiles < ActiveRecord::Migration
  def self.up
    create_table :profiles do |t|
      t.column :name, :string
      t.column :identifier, :string
      t.column :virtual_community_id, :integer
    end
  end

  def self.down
    drop_table :profiles
  end
end
