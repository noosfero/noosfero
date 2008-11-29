class AddDataToArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :setting, :text
    add_column :article_versions, :setting, :text
  end

  def self.down
    remove_column :articles, :setting
    remove_column :article_versions, :setting
  end
end
