class ChangingCreatedOnToAt < ActiveRecord::Migration
  def self.up
    rename_column :articles, :created_on, :created_at
    rename_column :articles, :updated_on, :updated_at

    rename_column :article_versions, :created_on, :created_at
    rename_column :article_versions, :updated_on, :updated_at

    rename_column :comments, :created_on, :created_at
  end

  def self.down
  end
end
