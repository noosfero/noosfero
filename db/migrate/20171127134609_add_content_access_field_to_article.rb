class AddContentAccessFieldToArticle < ActiveRecord::Migration[4.2]
  def up
    add_column :articles, :access, :integer, default: Entitlement::Levels.levels[:visitors]
  end

  def down
    remove_column :articles, :access
  end
end
