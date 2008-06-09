class AddPublishedFieldToArticle < ActiveRecord::Migration
  def self.up
    add_column :articles, :published, :boolean, :default => true
    execute('update articles set published = (1>0)')

    add_column :article_versions, :published, :boolean, :default => true
  end

  def self.down
    if self.select('select id from articles where not published').size > 0
      raise ActiveRecord::IrreversibleMigration, 'cannot remove published column, there are articles marked as not published'
    else
      remove_column :articles, :published
      remove_column :article_versions, :published
    end
  end
end
