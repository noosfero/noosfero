class CreateBlocks < ActiveRecord::Migration
  def self.up
    create_table :blocks do |t|
      t.column :name,     :string
      t.column :box_id,   :integer
      t.column :position, :integer
      t.column :type,     :string
    end
  end

  def self.down
    drop_table :blocks
  end
end
