class IndexArticlesFilteredFields < ActiveRecord::Migration
  def self.up
    %w[articles article_versions].each do |table|
      add_index table.to_sym, [:path]
      add_index table.to_sym, [:path, :profile_id]
    end
    add_index :articles, [:type]
    add_index :articles, [:type, :parent_id]
    add_index :articles, [:type, :profile_id]
  end

end
