class AddPublishedAtAndSourceToArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :published_at, :date
    add_column :article_versions, :published_at, :date

    execute('UPDATE articles SET published_at = created_at WHERE published_at IS NULL')
    execute('UPDATE article_versions SET published_at = created_at WHERE published_at IS NULL')

    add_column :articles, :source, :string, :null => true
    add_column :article_versions, :source, :string, :null => true
  end

  def self.down
    remove_column :articles, :published_at
    remove_column :article_versions, :published_at
    remove_column :articles, :source
    remove_column :article_versions, :source
  end
end
