class AddImageToArticle < ActiveRecord::Migration

  def self.up
    add_column :articles, :image_id, :integer
    add_column :article_versions, :image_id, :integer
  end

  def self.down
    remove_column :articles, :image_id
    remove_column :article_versions, :image_id
  end

end
