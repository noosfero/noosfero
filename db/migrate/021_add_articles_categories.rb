class AddArticlesCategories < ActiveRecord::Migration
  def self.up
    create_table :articles_categories do |t|
      t.column :article_id, :integer
      t.column :category_id, :integer
    end
    add_index(:articles_categories, :article_id)
    add_index(:articles_categories, :category_id)
  end

  def self.down
    drop_table :articles_categories
  end
end
