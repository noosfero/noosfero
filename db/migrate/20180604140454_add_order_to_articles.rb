class AddOrderToArticles < ActiveRecord::Migration[5.1]
  def up
    if !column_exists?(:articles, :position)
      add_column :articles, :position, :integer, default: 0
    else
      change_column :articles, :position, :integer, default: 0
    end
  end

  def down
    remove_column :articles, :position
  end
end
