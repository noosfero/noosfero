class FlexibleTemplateMigration < ActiveRecord::Migration
  def self.up
    create_table :design_boxes do |t|
      t.column :name,       :string
      t.column :title,    :string
      t.column :number,     :integer
      t.column :owner_type, :string
      t.column :owner_id,   :integer
    end

    create_table :design_blocks do |t|
      t.column :name,     :string
      t.column :title,    :string
      t.column :box_id,   :integer
      t.column :position, :integer
      t.column :type,     :string
      t.column :helper,   :string
    end

  end

  def self.down
    drop_table :design_boxes
    drop_table :design_blocks
  end

end
