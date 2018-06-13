class AddCssToBlocks < ActiveRecord::Migration
  def change
    add_column :blocks, :css, :string
  end
end
