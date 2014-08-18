class CreateRealRelationBetweenArticleAndAuthor < ActiveRecord::Migration
  def self.up
    add_column :articles, :author_id, :integer
    add_column :article_versions, :author_id, :integer

    # Set article's author as the first version's last_changed_by_id.
    execute "update articles set author_id = (select article_versions.last_changed_by_id from article_versions where article_versions.article_id = articles.id and article_versions.version = 1 limit 1)"
  end

  def self.down
    remove_column :articles, :author_id
    remove_column :article_versions, :author_id
  end
end
