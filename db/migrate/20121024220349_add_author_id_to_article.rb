class AddAuthorIdToArticle < ActiveRecord::Migration
  def self.up
    add_column :articles, :author_id, :integer
    add_column :article_versions, :author_id, :integer
  end

  def self.down
    remove_column :articles, :author_id
    remove_column :article_versions, :author_id, :integer
  end
end
