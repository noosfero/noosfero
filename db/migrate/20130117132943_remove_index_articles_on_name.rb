class RemoveIndexArticlesOnName < ActiveRecord::Migration
  def self.up
    remove_index :articles, :name
  end

  def self.down
    add_index :articles, :name
  end
end
