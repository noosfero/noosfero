class AddArchivedToArticles < ActiveRecord::Migration
  def up
    add_column :articles, :archived, :boolean, :default => false
  end

  def down
    remove_column :articles, :archived
  end
end
