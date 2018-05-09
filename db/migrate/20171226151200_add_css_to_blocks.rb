class AddCssToBlocks < ActiveRecord::Migration[5.1]
  def change
    add_column :blocks, :css, :string
  end
end
