class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.column :name,      :string
      t.column :slug,      :string
      t.column :path,      :text, :default => ''

      t.column :display_color,   :integer

      t.column :environment_id, :integer
      t.column :parent_id, :integer
      t.column :type,      :string
    end
  end

  def self.down
    drop_table :categories
  end
end
