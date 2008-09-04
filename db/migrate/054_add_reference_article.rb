class AddReferenceArticle < ActiveRecord::Migration
  def self.up
    add_column :articles, :reference_article_id, :integer
    add_column :article_versions, :reference_article_id, :integer
  end

  def self.down
    remove_column :articles, :reference_article_id
    remove_column :article_versions, :reference_article_id
  end
end
