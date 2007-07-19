class CreateProfiles < ActiveRecord::Migration
  def self.up
    create_table :profiles do |t|
      t.column :name,                 :string
      t.column :identifier,           :string
      t.column :virtual_community_id, :integer
      t.column :user_id,              :integer
      t.column :template,             :string, :default => "default"
      t.column :theme,                :string, :default => "default"
      t.column :icons_theme,          :string, :default => "default"
    end
  end

  def self.down
    drop_table :profiles
  end
end
