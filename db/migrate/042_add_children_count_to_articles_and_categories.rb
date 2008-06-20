class AddChildrenCountToArticlesAndCategories < ActiveRecord::Migration
  def self.up
    add_column :articles, :children_count, :integer, :default => 0
    execute 'update articles set children_count = (select count(*) from articles a2 where (a2.parent_id = articles.id) )'

    add_column :article_versions, :children_count, :integer, :default => 0

    add_column :categories, :children_count, :integer, :default => 0
    execute 'update categories set children_count = (select count(*) from categories c2 where (c2.parent_id = categories.id) )'
  end

  def self.down
    remove_column :articles, :children_count
    remove_column :article_versions, :children_count

    remove_column :categories, :children_count
  end
end
