class CreateProfiles < ActiveRecord::Migration
  def self.up
    create_table :profiles do |t|
      t.column :name, :string
      t.column :identifier, :string
    end
  end

  def self.down
    drop_table :profiles
  end
end
