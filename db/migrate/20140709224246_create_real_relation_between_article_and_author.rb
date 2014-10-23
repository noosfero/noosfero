class CreateRealRelationBetweenArticleAndAuthor < ActiveRecord::Migration
  def self.up
    add_column :articles, :author_id, :integer
    add_column :article_versions, :author_id, :integer

    # Set article's author as the first version's last_changed_by_id.
    execute("UPDATE article_versions SET author_id = last_changed_by_id")

    execute("UPDATE articles SET author_id = article_versions.author_id FROM article_versions WHERE article_versions.article_id = articles.id AND article_versions.version = 1")
 end

  def self.down
    remove_column :articles, :author_id
    remove_column :article_versions, :author_id
  end
end
