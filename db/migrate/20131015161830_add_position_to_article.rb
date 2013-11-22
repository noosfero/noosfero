class AddPositionToArticle < ActiveRecord::Migration

  def self.up
    add_column :articles, :position, :integer
    add_column :article_versions, :position, :integer
  end

  def self.down
    remove_column :articles, :position
    remove_column :article_versions, :position
  end

end
