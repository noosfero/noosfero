class AddExternalLinkToArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :external_link, :string
    add_column :article_versions, :external_link, :string
  end

  def self.down
    remove_column :articles, :external_link
    remove_column :article_versions, :external_link
  end
end
