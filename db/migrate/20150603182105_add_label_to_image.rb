class AddLabelToImage < ActiveRecord::Migration
  def up
    add_column :images, :label, :string, :default => ""
  end
  def down
    remove_column :images, :label
  end
end
