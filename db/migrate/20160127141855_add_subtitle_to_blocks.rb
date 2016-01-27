class AddSubtitleToBlocks < ActiveRecord::Migration
  def up
    add_column :blocks, :subtitle, :string, :default => ""
  end
  def down
    remove_column :blocks, :subtitle
  end
end
