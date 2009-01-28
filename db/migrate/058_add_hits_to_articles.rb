class AddHitsToArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :hits, :integer, :default => 0
    add_column :article_versions, :hits, :integer, :default => 0
    execute('update articles set hits = 0')
  end

  def self.down
    remove_column :articles, :hits
    remove_column :article_versions, :hits
  end
end
