class AddMirrorToBlock < ActiveRecord::Migration
  def up
    change_table :blocks do |t|
      t.boolean :mirror, :default => false
      t.references :mirror_block
      t.references :observers
    end
  end

  def down
    remove_column :blocks, :mirror
    remove_column :blocks, :mirror_block_id
    remove_column :blocks, :observers_id
  end
end
