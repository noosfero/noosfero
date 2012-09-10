class AddLicenseToArticle < ActiveRecord::Migration
  def self.up
    add_column :articles, :license_id, :integer
    add_column :article_versions, :license_id, :integer
  end

  def self.down
    remove_column :articles, :license_id
    remove_column :article_versions, :license_id
  end
end
