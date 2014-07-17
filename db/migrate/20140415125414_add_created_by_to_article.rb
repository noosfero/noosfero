class AddCreatedByToArticle < ActiveRecord::Migration
  def self.up
    add_column :articles, :created_by_id, :integer
    add_column :article_versions, :created_by_id, :integer

    execute("UPDATE article_versions SET created_by_id = last_changed_by_id")

    execute("UPDATE articles SET created_by_id = article_versions.created_by_id
FROM article_versions WHERE article_versions.article_id = articles.id AND
article_versions.version = 1")
  end

  def self.down
    remove_column :articles, :created_by_id
    remove_column :article_versions, :created_by_id
  end
end
