class SpecializeArticles < ActiveRecord::Migration
  def self.up
    execute "update articles set type = 'TinyMceArticle' where type = 'Article'"
  end

  def self.down
    raise ActiveRecord::Migration::IrreversibleMigration, 'cannot reverse this'
  end
end
