class CreateBlocks < ActiveRecord::Migration
  def self.up
    create_table :blocks do |t|
      t.column :box_id,   :integer
      t.column :position, :integer
    end
  end

  def self.down
    drop_table :blocks
  end
end
