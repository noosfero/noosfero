class AddHighlightedToArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :highlighted, :boolean, :default => false
    add_column :article_versions, :highlighted, :boolean, :default => false
  end

  def self.down
    remove_column :articles, :highlighted
    remove_column :article_versions, :highlighted
  end
end
