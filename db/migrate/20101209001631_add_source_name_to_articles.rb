class AddSourceNameToArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :source_name, :string, :null => true
    add_column :article_versions, :source_name, :string, :null => true
  end

  def self.down
    remove_column :articles, :source_name
    remove_column :article_versions, :source_name
  end
end
