class CreateProfiles < ActiveRecord::Migration
  def self.up
    create_table :profiles do |t|
      t.column :name,                 :string
      t.column :identifier,           :string
      t.column :virtual_community_id, :integer
      t.column :profile_owner_id,     :integer
      t.column :profile_owner_type,   :string
      t.column :flexible_template_template,             :string, :default => "default"
      t.column :flexible_template_theme,                :string, :default => "default"
      t.column :flexible_template_icon_theme,           :string, :default => "default"
    end
  end

  def self.down
    drop_table :profiles
  end
end
