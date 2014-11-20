class AddIndexToBlogPostsSort < ActiveRecord::Migration
  def self.up
     %w[articles article_versions].each do |table|
      add_index table.to_sym, [:published_at, :id]
    end
 end

  def self.down
     %w[articles article_versions].each do |table|
      remove_index table.to_sym, [:published_at, :id]
    end
  end
end
