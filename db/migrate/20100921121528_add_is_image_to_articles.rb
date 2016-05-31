class AddIsImageToArticles < ActiveRecord::Migration
  def self.up
     add_column :articles, :is_image, :boolean, :default => false
     add_column :article_versions, :is_image, :boolean, :default => false

     execute ApplicationRecord.sanitize_sql(["update articles set is_image = ? where articles.content_type like 'image/%'", true])
  end

  def self.down
     remove_column :articles, :is_image
     remove_column :article_versions, :is_image
  end
end
